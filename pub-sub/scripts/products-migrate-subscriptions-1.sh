#!/bin/bash
## ================================================
# Goal: Migrate Product subscriptions in batches, one Consumer Org at a time
# Use CLI: products:migrate-subscriptions
# Collect all apps for the Consumer Org in the Catalog
# For each app
#   Collect subscriptions in a common file
# Collect all plans in the Product
#     make source & target plans names the same. (defer tweaks)
# Compose MIGRATE_SUBSCRIPTION_SUBSET_FILE
# Run products:migrate-subscriptions with the plan's MIGRATE_SUBSCRIPTION_SUBSET_FILE
# Print migrated subscriptions ID, consumer app name & consumer org name
## ================================================
APIC_TOOLKIT="./apic"
APIC_OUPUT_DIR="./apic-output"
SERVER=apim.mgmt.dev.apic.xxxxxx.test
P_ORG=p1org                 # Provider Organization
CATALOG=sandbox
C_ORG=sandbox-corg          # Consumer Organization
C_ORG_URL=""
APP=""
SOURCE_PRODUCT_NAME=pokemon
SOURCE_PRODUCT_VERSION=2.0.0
SOURCE_PRODUCT_URL=""
TARGET_PRODUCT_NAME=pokemon
TARGET_PRODUCT_VERSION=2.0.2
TARGET_PRODUCT_URL=""

## ================================================
## 2021-03-10  To Do
## ------------------------------------
## - Include only apps & subscritions with state = enabled
## ================================================
# Create APIC_OUPUT_DIR directory if it does not exist.
if [[ ! -d "${APIC_OUPUT_DIR}" ]];
then
  mkdir ${APIC_OUPUT_DIR}
else
  # Delete product json file, if it exists
  if [[ -e "${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}.json" && -f "${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}.json" ]]; then
      rm ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}.json;
  fi
  # Delete Source Product Subscription file, if it exists
  if [[ -e "${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_SubsURL.txt" && -f "${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_SubsURL.txt" ]]; then
      rm ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_SubsURL.txt;
  fi
  # Delete Consumer Org json file, if it exists
  if [[ -e "${APIC_OUPUT_DIR}/$C_ORG.json" && -f "${APIC_OUPUT_DIR}/$C_ORG.json" ]]; then
      rm ${APIC_OUPUT_DIR}/${C_ORG}.json;
  fi
  # Delete MIGRATE_SUBSCRIPTION_SUBSET_FILE, if it exists
  if [[ -e "${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt" && -f "${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt" ]]; then
      rm ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt;
  fi
fi

## ================================================
# Capture Source product_url to filter subscriptions
SOURCE_PRODUCT_URL=$( ${APIC_TOOLKIT} products:list --scope catalog --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} ${SOURCE_PRODUCT_NAME} | grep ${SOURCE_PRODUCT_VERSION} | awk '{print $4}' )

# Capture Target Product URL
TARGET_PRODUCT_URL=$( ${APIC_TOOLKIT} products:list --scope catalog --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} ${TARGET_PRODUCT_NAME} | grep ${TARGET_PRODUCT_VERSION} | awk '{print $4}' )

#Capture Consumer Org URL to filter apps. Send console output to > /dev/null
${APIC_TOOLKIT} consumer-orgs:get --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} --format json --output ${APIC_OUPUT_DIR} $C_ORG > /dev/null
C_ORG_URL=$( cat ${APIC_OUPUT_DIR}/$C_ORG.json | jq ' .url ' )

## ================================================
# Capture all apps for the consumer org in the Catalog
# -----------------------------------------
${APIC_TOOLKIT} apps:list --scope catalog --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} --format json | jq --argjson corgurl $C_ORG_URL ' [ if .results[].consumer_org_url == $corgurl then .results[].name else "null" end ] | unique | .[] | select(. != "null") ' > ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Apps.txt

## ================================================
# Collect Subscription ID which belong to the Consumer Org for apps subscribed to the Source Product
# -----------------------------------------
# An App can subscribe only once to a Prodcut:Version. But an app could subscribe to other Products:Versions. The jq select filter returns only subscriptions to the Source Product:Version.
# -----------------------------------------
while read app
do
  APP=$( echo $app | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
  if [ $APP != 'sandbox-test-app' ]                         # Default Sandbox Catalog app
    then
      ${APIC_TOOLKIT} subscriptions:list --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} --consumer-org ${C_ORG} --app $APP --fields url,product_url --format json | jq --arg spurl $SOURCE_PRODUCT_URL ' .results[] | select(.product_url == $spurl) | .url  ' >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_SubsURL.txt
  fi
done < ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Apps.txt
## ------------------------------------
# ${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_SubsURL.txt will have "null"
# for apps which do not have subscriptions for the Source Product:Version.
# Need to ignore "null" entries in downstream processing.
## ------------------------------------

## ================================================
# Compose MIGRATE_SUBSCRIPTION_SUBSET_FILE for products:migrate-subscriptions
## --------------------------------------
# Refer to IBM KC https://www.ibm.com/support/knowledgecenter/SSMNED_v10/com.ibm.apic.reference.doc/rapic_rest_apis.html, navigate IBM API Connect Platfore - Provider API section annd search for "Migrate list of subscriptions between products". The example & schema definition for the "body" are specifications for MIGRATE_SUBSCRIPTION_SUBSET_FILE.
## --------------------------------------
# subscription_urls:
# - {subscription url to source product:version}
# - {subscription url to source product:version}
# - {subscription url to source product:version}
# product_url: {source product_url}
# plans:
# - source: {plan name in source product:version}
#   target: {plan name in target product:version}
# - source: {plan name in source product:version}
#   target: {plan name in target product:version}
# ## -------- Subscription URLs ------------------------------
echo "subscription_urls:" > ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt

while read subsurl
do
  SUBSURL=$( echo $subsurl | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
  if [ $SUBSURL != 'null' ]                         # app does not have subscription
    then
      echo "- $SUBSURL" >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt
  fi
done < ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_SubsURL.txt
## -------- Source Product URL  ----------------------
echo "product_url: $SOURCE_PRODUCT_URL" >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt
## -------- plans:  ----------------------
echo "plans:" >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt

## ------------------------------------------------
# Get Plans for the Product. Send annoying STDOUT to /dev/null
${APIC_TOOLKIT} products:get --scope catalog --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} --format json --output ${APIC_OUPUT_DIR} --fields "name,version,plans" ${SOURCE_PRODUCT_NAME}:${SOURCE_PRODUCT_VERSION} > /dev/null

jq '.plans[].name' ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}.json > ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Plans.txt

echo  "-------------------------------------------------------"
echo "Plans in Source Product *${SOURCE_PRODUCT_NAME}:${SOURCE_PRODUCT_VERSION}*"
echo  "-------------------------------------------------------"
cat ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Plans.txt

# Loop puts Source Product plan names into MIGRATE_SUBSCRIPTION_SUBSET_FILE
# In most cases, source & target Products will have plans with identical names
# In the event plan names differ, the user can edit and make corrections
while read plan
do
echo "- source: $plan" >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt
echo "  target: $plan" >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt
done < ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Plans.txt

echo  "-------------------------------------------------------"
echo "Product MIGRATE_SUBSCRIPTION_SUBSET_FILE:" ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_migrate-subscriptions.txt
echo  "-------------------------------------------------------"
