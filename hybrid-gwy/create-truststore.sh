#!/bin/bash
## ================================================
# Goal: Create APIC Truststore in Cloud Manager (not API Manager)
# ---------------------------------
# Login to org "admin", with admin rights. By default, user "admin",
# realm "admin/default-idp-1", server "<platform-api endpoint>"
## ================================================
APIC_TOOLKIT="./apic"
APIC_OUTPUT_DIR="./apic-output"
# -----------------------------------------
# Should be the "platform-api" endpoint
SERVER=platform.mgmt.dev.apic.ibmlab.test
ADMIN_ORG=admin                 # admin Organization
# -----------------------------------------
# See companion document "TLS-for-Hybrid-DataPowerGateway.md" for definitions
# of certificate files.
# -----------------------------------------
CERT_PEM="my-ca-cert.pem"
PATH_2_PEM="/home/rramnara/git/internal-ibm/apic-hybrid-gwy/Hybrid-TLS"
# -----------------------------------------
# You SHOULD enter a unique, lower-case value for TRUSTSTORE_NAME. Otherwise, you will
# create duplicate entries with TRUSTSTORE_TITLE if you run the script more than once.
TRUSTSTORE_TITLE="RR-Truststore-2"
TRUSTSTORE_NAME="rr-truststore-2"
# -----------------------------------------
SUMMARY=""
TRUSTSTORE_FILE="truststore-file.json"
## ================================================
# Remove old output files
# -----------------------------------------
if [[ ! -d "${APIC_OUTPUT_DIR}" ]];
then
  # Create APIC_OUTPUT_DIR directory if it does not exist.
  mkdir ${APIC_OUTPUT_DIR}
else
  # Delete APIC_OUTPUT_DIR directory and contents
  rm -rf ${APIC_OUTPUT_DIR}
  # Create APIC_OUTPUT_DIR directory
  mkdir ${APIC_OUTPUT_DIR}
fi
## ================================================
# Generate TRUSTSTORE_NAME to avoid creating "false" duplicates
# -----------------------------------------
# Compose Truststore Body: CERT_PEM
# Need to insert "/n" at end of each line in PEM
# -----------------------------------------
index="0"
while read pemline
do
  pemline=$( echo $pemline | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks
  if [ $index -eq 0 ]
  then
    truststore_value=${pemline}"\n"
  else
    truststore_value=${truststore_value}${pemline}"\n"
  fi
  index=$[ $index + 1 ]
done < ${PATH_2_PEM}/${CERT_PEM}
# -----------------------------------------
req_json_body='{"title":"'${TRUSTSTORE_TITLE}'","name":"'${TRUSTSTORE_NAME}'","summary":"'${SUMMARY}'","truststore":"'${truststore_value}'"}'

echo ${req_json_body} > ${TRUSTSTORE_FILE}

# -----------------------------------------
${APIC_TOOLKIT} truststores:create --org ${ADMIN_ORG} --server ${SERVER} --format json --output ${APIC_OUTPUT_DIR} ${TRUSTSTORE_FILE}
## ================================================
