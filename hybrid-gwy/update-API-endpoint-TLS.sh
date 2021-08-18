#!/bin/bash
## ================================================
# Goal: Apply Server TLS Profile to Gateway API endpoint in Cloud Manager
# ---------------------------------
# Login to org "admin", with admin rights. By default, user "admin",
# realm "admin/default-idp-1", server "<platform-api endpoint>"
## ================================================
# This implementation replaces existing SNI entries with a new set.
# The new set might contain one or more existing SNI entries. You should specify
# the complete set of desired array of SNI entries. This tool does not "edit" the
# existing SNI entries. It just replaces them with the new set. One "host-value"
# should be "*". If you wish to edit existing entries you can parse the output of
# gateway-services:get (recommend "yq" over "jq").
# -----------------------------------------
APIC_TOOLKIT="./apic"
APIC_OUTPUT_DIR="./apic-output"
# -----------------------------------------
# Enter APIGW NAME, not TITLE
APIGW_NAME="apigw1"
# -----------------------------------------
# Should be the "platform-api" endpoint
SERVER=platform.mgmt.dev.apic.xxxxxx.test
ADMIN_ORG=admin                 # admin Organization
# Use the default AVAILABILITY_ZONE, unless you have tweaked it (rare)
AVAILABILITY_ZONE="availability-zone-default"
## ================================================
# SNI & TLS entries
# -----------------------------------------
DEFAULT_TLS_SERVER_PROFILE_NAME="tls-server-profile-default"
DEFAULT_TLS_SERVER_PROFILE_VERSION="1.0.0"
# -----------------------------------------
API_SERVER_1_SNI="*.xxxxxx.org"
TLS_SERVER_PROFILE_1_NAME="server-tls-1"
TLS_SERVER_PROFILE_1_VERSION="1.0.0"
# -----------------------------------------
API_SERVER_2_SNI="*.apic.xxxxxx.test"
TLS_SERVER_PROFILE_2_NAME="server-tls-2"
TLS_SERVER_PROFILE_2_VERSION="1.0.0"
# -----------------------------------------
APIGW_REQ_FILE="apigw-req-file.json"
## ================================================
# Function to retrieve TLS profile url
# -----------------------------------------
TLS_PROFILE_NAME=""
TLS_PROFILE_VERSION=""
TLS_PROFILE_URL=""
# -----------------------------------------
geturl()
{
  TLS_PROFILE_URL=$( ${APIC_TOOLKIT} tls-server-profiles:get --org ${ADMIN_ORG} --server ${SERVER} --fields url --output ${APIC_OUTPUT_DIR} ${TLS_PROFILE_NAME}:${TLS_PROFILE_VERSION} | awk '{print $3}' )
  rm ${APIC_OUTPUT_DIR}/TLSServerProfile.yaml
}
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
# You can keep "tls-server-profile-default" or assign a custom
# TLS_SERVER_PROFILE_NAME to host="*".
# Syntax of SNI Array:
# SNI_ARRAY='[{"host":"*","tls_server_profile_url":"<URL>"},{"host":"<SERVER_1_SNI>","tls_server_profile_url":"<TLS_1_URL>"},{"host":"<SERVER_2_SNI>","tls_server_profile_url":"<TLS_2_URL>"}]'
# -----------------------------------------
# Code below is NOT elegant. It works. Code retains the "default" TLS server profile
# for host="*" and adds two SNI with custom TLS profiles. We could have assigned
# a custom TLS server profile to host="*" without adding any extra SNI entries.
# -----------------------------------------
DBL_QUOTE='"'
COMMA=","
SNI_ARRAY='[{"host":"*","tls_server_profile_url"'
# -----------------------------------------
TLS_PROFILE_NAME=$DEFAULT_TLS_SERVER_PROFILE_NAME
TLS_PROFILE_VERSION=$DEFAULT_TLS_SERVER_PROFILE_VERSION
geturl
SNI_ARRAY=${SNI_ARRAY}:${DBL_QUOTE}${TLS_PROFILE_URL}${DBL_QUOTE}"}"
# -----------------------------------------
TLS_PROFILE_NAME=$TLS_SERVER_PROFILE_1_NAME
TLS_PROFILE_VERSION=$TLS_SERVER_PROFILE_1_VERSION
geturl
SNI_ARRAY=${SNI_ARRAY}${COMMA}'{"host"':${DBL_QUOTE}${API_SERVER_1_SNI}${DBL_QUOTE},'"tls_server_profile_url"':${DBL_QUOTE}${TLS_PROFILE_URL}${DBL_QUOTE}"}"
# -----------------------------------------
TLS_PROFILE_NAME=$TLS_SERVER_PROFILE_2_NAME
TLS_PROFILE_VERSION=$TLS_SERVER_PROFILE_2_VERSION
geturl
SNI_ARRAY=${SNI_ARRAY}${COMMA}'{"host"':${DBL_QUOTE}${API_SERVER_2_SNI}${DBL_QUOTE},'"tls_server_profile_url"':${DBL_QUOTE}${TLS_PROFILE_URL}${DBL_QUOTE}"}"
# -----------------------------------------
SNI_ARRAY=${SNI_ARRAY}"]"
# echo ${SNI_ARRAY}
# -----------------------------------------
# Just the bare minimum to update the SNI_ARRAY in APIGW
APIGW_REQ_BODY='{"name":"'${APIGW_NAME}'","sni":'${SNI_ARRAY}'}'
# -----------------------------------------
echo ${APIGW_REQ_BODY} > ${APIC_OUTPUT_DIR}/${APIGW_REQ_FILE}
# -----------------------------------------
${APIC_TOOLKIT}  gateway-services:update --availability-zone ${AVAILABILITY_ZONE} --org ${ADMIN_ORG} --server ${SERVER} --format yaml --output ${APIC_OUTPUT_DIR} ${APIGW_NAME} ${APIC_OUTPUT_DIR}/${APIGW_REQ_FILE}
# ================================================
# You could validate success by examining the output file or with gateway-services:get
# -----------------------------------------
