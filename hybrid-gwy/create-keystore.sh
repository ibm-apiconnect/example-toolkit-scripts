#!/bin/bash
## ================================================
# Goal: Create APIC Keystore in Cloud Manager (not API Manager)
# ---------------------------------
# Login to org "admin", with admin rights. By default, user "admin",
# realm "admin/default-idp-1", server "<platform-api endpoint>"
## ================================================
APIC_TOOLKIT="./apic"
APIC_OUPUT_DIR="./apic-output"
# -----------------------------------------
# Should be the "platform-api" endpoint
SERVER=platform.mgmt.dev.apic.xxxxx.test
ADMIN_ORG=admin                 # admin Organization
# -----------------------------------------
# See companion document "TLS-for-Hybrid-DataPowerGateway.md" for definitions
# of certificate files.
# -----------------------------------------
# Include leaf, intermediate & root CA certificates in CERT_PEM
# -----------------------------------------
CERT_PEM="my-apic-cert-bundle.pem"
PRIKEY_PEM="my-apic-prikey.pem"
PATH_2_PEM="<replace with path to folder with pem files>"
# -----------------------------------------
# You SHOULD enter a unique, lower-case value for KEYSTORE_NAME. Otherwise, you will
# create duplicate entries with KEYSTORE_TITLE if you run the script more than once.
KEYSTORE_TITLE="RR-Keystore-2"
KEYSTORE_NAME="rr-keystore-2"
# -----------------------------------------
SUMMARY=""
KEYSTORE_FILE="keystore-file.json"
## ================================================
# Remove old output files
# -----------------------------------------
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
# Generate KEYSTORE_NAME to avoid creating "false" duplicates
# -----------------------------------------
# Compose Keystore Body: CERT_PEM + PRIKEY_PEM
# Need to insert "/n" at end of each line in PEM
# -----------------------------------------
index="0"
while read pemline
do
  pemline=$( echo $pemline | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
  if [ $index -eq 0 ]
  then
    keystore_value=${pemline}"\n"
  else
    keystore_value=${keystore_value}${pemline}"\n"
  fi
  index=$[ $index + 1 ]
done < ${PATH_2_PEM}/${CERT_PEM}
# -----------------------------------------
while read pemline
do
  pemline=$( echo $pemline | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
  keystore_value=${keystore_value}${pemline}"\n"
done < ${PATH_2_PEM}/${PRIKEY_PEM}

# -----------------------------------------
req_json_body='{"title":"'${KEYSTORE_TITLE}'","name":"'${KEYSTORE_NAME}'","summary":"'${SUMMARY}'","keystore":"'${keystore_value}'"}'

echo ${req_json_body} > ${KEYSTORE_FILE}

# -----------------------------------------
${APIC_TOOLKIT} keystores:create --org ${ADMIN_ORG} --server ${SERVER} --format json --output ${APIC_OUPUT_DIR} ${KEYSTORE_FILE}
## ================================================
