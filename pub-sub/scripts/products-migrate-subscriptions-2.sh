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
SERVER=apim.mgmt.dev.apic.ibmlab.test
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
## - Ensure Target Product:Version is PUBLISHED
## - Set Source Product state to Deprecated
## - Use jq to extract a summary from the command output
## ================================================
# products:migrate-subscription (flags) Target-Product:Version MIGRATE_SUBSCRIPTION_SUBSET_FILE
# -----------------------------------------
${APIC_TOOLKIT} products:migrate-subscriptions --scope catalog --catalog ${CATALOG} --org ${P_ORG} --server ${SERVER} --format json --output ${APIC_OUPUT_DIR} ${TARGET_PRODUCT_NAME}:${TARGET_PRODUCT_VERSION} ${APIC_OUPUT_DIR}/${SOURCE_PRODUCT_NAME}_${SOURCE_PRODUCT_VERSION}__migrate-subscriptions.txt

## ================================================
# The command will fail if
# - Subscription(s) do not belong to the Source Product:Version
#   This condition is unlikely as the previous steps collects subscriptions for the Source Product:Version
# - Consumer App already subscribes to the Target Product:Version
#   We could mitigate this condition by running the "product-subs-for-corg.sh" on the Target Prodcut:Version
## ------------------------------------------------
