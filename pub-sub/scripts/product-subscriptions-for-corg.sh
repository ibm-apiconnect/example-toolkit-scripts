#!/bin/bash
## ================================================
# Goal: List subscription by Customer / Product:Version / Plan Name / App Name
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
if [[ ! -d "${APIC_OUPUT_DIR}" ]];
then
  # Create APIC_OUPUT_DIR directory if it does not exist.
  mkdir ${APIC_OUPUT_DIR}
else
  # Delete APIC_OUPUT_DIR directory and contents
  rm -rf ${APIC_OUPUT_DIR}
  # Create APIC_OUPUT_DIR directory
  mkdir ${APIC_OUPUT_DIR}
fi
## ================================================
# Capture Source product_url to filter subscriptions
SOURCE_PRODUCT_URL=$( ${APIC_TOOLKIT} products:list --scope catalog --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} ${SOURCE_PRODUCT_NAME} | grep ${SOURCE_PRODUCT_VERSION} | awk '{print $4}' )

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
  if [ $APP != 'sandbox-test-app' ]                         # Skip Sandbox Catalog test app
    then
      ${APIC_TOOLKIT} subscriptions:list --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} --consumer-org ${C_ORG} --app $APP --fields plan,product_url --format json | jq --arg spurl $SOURCE_PRODUCT_URL ' .results[] | select(.product_url == $spurl) | .plan  '  > ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_${C_ORG}_${APP}_Plans.txt
  fi
done < ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Apps.txt
## ================================================
# Produce a human readable CSV with Consumer Org, App, Source Product:Version, Plan
## ------------------------------------
echo "Consumer-Org,App-Name,Source-Product:Version,Plan-Name" > ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_${C_ORG}_App_Subs.CSV

while read app
do
  APP=$( echo $app | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
  if [ $APP != 'sandbox-test-app' ]                         # Skip Sandbox Catalog test app
    then
      while read plan
      do
        PLAN_NAME=$( echo $plan | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
        echo "${C_ORG},${APP},${SOURCE_PRODUCT_NAME}:${SOURCE_PRODUCT_VERSION},${PLAN_NAME}" >> ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_${C_ORG}_App_Subs.CSV
      done < ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_${C_ORG}_${APP}_Plans.txt
fi
done < ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_Apps.txt
## ================================================
echo "## ------------------------------------"
echo "Product-ConsumerOrg-App-Subscription report:" ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}_${C_ORG}_App_Subs.CSV
echo "## ------------------------------------"
## ================================================
