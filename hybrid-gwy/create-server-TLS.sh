#!/bin/bash
## ================================================
# Goal: Create Server TLS in Cloud Manager (not API Manager)
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
# Enter NAME for Key & Trust Stores, not TITLE
TRUSTSTORE_NAME="rr-truststore-2"
KEYSTORE_NAME="rr-keystore-2"
# -----------------------------------------
TLS_SERVER_PROFILE_TITLE='RR-Server-TLS-2'
TLS_SERVER_PROFILE_NAME='rr-server-tls-2'
VERSION='1.0.0'
SUMMARY=""
# mutual_authentication can be "none", "request" or "require"
MUTUAL_AUTHENTICATION='none'
LIMIT_RENEGOTIATION='true'
KEYSTORE_URL=''
TRUSTSTORE_URL=''
# -----------------------------------------
# Make sure you are okay with the list of CIPHERS. This list came from the TLS UI.
# Consider updating this when a new version of API Connect arrives.
# Do you want to include ciphers supported by TLS v1.3?
# The following are TLS v1.2 ciphers.
CIPHERS='["ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","ECDHE_RSA_WITH_AES_256_GCM_SHA384","ECDHE_ECDSA_WITH_AES_256_CBC_SHA384","ECDHE_RSA_WITH_AES_256_CBC_SHA384","ECDHE_ECDSA_WITH_AES_256_CBC_SHA","ECDHE_RSA_WITH_AES_256_CBC_SHA","DHE_DSS_WITH_AES_256_GCM_SHA384","DHE_RSA_WITH_AES_256_GCM_SHA384","DHE_RSA_WITH_AES_256_CBC_SHA256","DHE_DSS_WITH_AES_256_CBC_SHA256","DHE_RSA_WITH_AES_256_CBC_SHA","DHE_DSS_WITH_AES_256_CBC_SHA","RSA_WITH_AES_256_GCM_SHA384","RSA_WITH_AES_256_CBC_SHA256","RSA_WITH_AES_256_CBC_SHA","ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","ECDHE_RSA_WITH_AES_128_GCM_SHA256","ECDHE_ECDSA_WITH_AES_128_CBC_SHA256","ECDHE_RSA_WITH_AES_128_CBC_SHA256","ECDHE_ECDSA_WITH_AES_128_CBC_SHA","ECDHE_RSA_WITH_AES_128_CBC_SHA","DHE_DSS_WITH_AES_128_GCM_SHA256","DHE_RSA_WITH_AES_128_GCM_SHA256","DHE_RSA_WITH_AES_128_CBC_SHA256","DHE_DSS_WITH_AES_128_CBC_SHA256","DHE_RSA_WITH_AES_128_CBC_SHA","DHE_DSS_WITH_AES_128_CBC_SHA","RSA_WITH_AES_128_GCM_SHA256","RSA_WITH_AES_128_CBC_SHA256","RSA_WITH_AES_128_CBC_SHA"]'
# -----------------------------------------
# Valid protocols for APIC v10 are "tls_v1.2" and "tls_v1.3"
# To use TLS v1.3, you need to add appropriate ciphers above
PROTOCOLS='["tls_v1.2"]'

TLS_SERVER_PROFILE_FILE="tls_server_profile_file.json"
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
# Get the URL for Key & Trust Stores to compose the request
# -----------------------------------------
${APIC_TOOLKIT} keystores:get --org ${ADMIN_ORG} --server ${SERVER} --format json --fields "name,url" --output ${APIC_OUTPUT_DIR} ${KEYSTORE_NAME}

KEYSTORE_URL=$( cat ${APIC_OUTPUT_DIR}/${KEYSTORE_NAME}.json | jq ' .url ' )
KEYSTORE_URL=$( echo ${KEYSTORE_URL} | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks

${APIC_TOOLKIT} truststores:get --org ${ADMIN_ORG} --server ${SERVER} --format json --fields "name,url" --output ${APIC_OUTPUT_DIR} ${TRUSTSTORE_NAME}

TRUSTSTORE_URL=$( cat ${APIC_OUTPUT_DIR}/${TRUSTSTORE_NAME}.json | jq ' .url ' )
TRUSTSTORE_URL=$( echo ${TRUSTSTORE_URL} | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks

# -----------------------------------------
req_json_body='{"title":"'${TLS_SERVER_PROFILE_TITLE}'","name":"'${TLS_SERVER_PROFILE_NAME}'","version":"'${VERSION}'","summary":"'${SUMMARY}'","mutual_authentication":"'${MUTUAL_AUTHENTICATION}'","limit_renegotiation":'${LIMIT_RENEGOTIATION}',"keystore_url":"'${KEYSTORE_URL}'","truststore_url":"'${TRUSTSTORE_URL}'","protocols":'${PROTOCOLS}',"ciphers":'${CIPHERS}'}'

echo ${req_json_body} > ${APIC_OUTPUT_DIR}/${TLS_SERVER_PROFILE_FILE}

# -----------------------------------------
${APIC_TOOLKIT} tls-server-profiles:create --org ${ADMIN_ORG} --server ${SERVER} --format json --output ${APIC_OUTPUT_DIR} ${APIC_OUTPUT_DIR}/${TLS_SERVER_PROFILE_FILE}
## ================================================
# You could validate success by examining the output file or by retrieving the
# URL for the TLS Server profile
# -----------------------------------------
