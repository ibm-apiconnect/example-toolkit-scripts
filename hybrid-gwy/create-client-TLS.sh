#!/bin/bash
## ================================================
# Goal: Create Client TLS in Cloud Manager (not API Manager)
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
# Enter NAME for Key & Trust Stores, not TITLE
TRUSTSTORE_NAME="rr-truststore-2"
KEYSTORE_NAME="rr-keystore-2"
# -----------------------------------------
# Note: Title & Name are different data attributes
TLS_CLIENT_PROFILE_TITLE='RR-Client-TLS-2'
TLS_CLIENT_PROFILE_NAME='rr-client-tls-2'
# -----------------------------------------
VERSION='1.0.0'
SUMMARY=""
INSECURE_SERVER_CONNECTIONS='false'
SERVER_NAME_INDICATION='true'
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

TLS_CLIENT_PROFILE_FILE="tls_client_profile_file.json"
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
# Get the URL for Key & Trust Stores to compose the request
# -----------------------------------------
${APIC_TOOLKIT} keystores:get --org ${ADMIN_ORG} --server ${SERVER} --format json --fields "name,url" --output ${APIC_OUPUT_DIR} ${KEYSTORE_NAME}

KEYSTORE_URL=$( cat ${APIC_OUPUT_DIR}/${KEYSTORE_NAME}.json | jq ' .url ' )
KEYSTORE_URL=$( echo ${KEYSTORE_URL} | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks

${APIC_TOOLKIT} truststores:get --org ${ADMIN_ORG} --server ${SERVER} --format json --fields "name,url" --output ${APIC_OUPUT_DIR} ${TRUSTSTORE_NAME}

TRUSTSTORE_URL=$( cat ${APIC_OUPUT_DIR}/${TRUSTSTORE_NAME}.json | jq ' .url ' )
TRUSTSTORE_URL=$( echo ${TRUSTSTORE_URL} | sed "s/^\([\"']\)\(.*\)\1\$/\2/g" )    # Strip quote marks

# -----------------------------------------
req_json_body='{"title":"'${TLS_CLIENT_PROFILE_TITLE}'","name":"'${TLS_CLIENT_PROFILE_NAME}'","version":"'${VERSION}'","summary":"'${SUMMARY}'","insecure_server_connections":'${INSECURE_SERVER_CONNECTIONS}',"server_name_indication":'${SERVER_NAME_INDICATION}',"keystore_url":"'${KEYSTORE_URL}'","truststore_url":"'${TRUSTSTORE_URL}'","protocols":'${PROTOCOLS}',"ciphers":'${CIPHERS}'}'

echo ${req_json_body} > ${APIC_OUPUT_DIR}/${TLS_CLIENT_PROFILE_FILE}

# -----------------------------------------
${APIC_TOOLKIT} tls-client-profiles:create --org ${ADMIN_ORG} --server ${SERVER} --format json --output ${APIC_OUPUT_DIR} ${APIC_OUPUT_DIR}/${TLS_CLIENT_PROFILE_FILE}
## ================================================
# You could validate success by examining the output file or by retrieving the
# URL for the TLS Client profile
# -----------------------------------------
