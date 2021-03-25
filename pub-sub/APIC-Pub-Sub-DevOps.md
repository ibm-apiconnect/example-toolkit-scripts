# IBM API Connect  
> ## DevOps for API Products & Consumer Subscriptions  
>  Ravi Ramnarayan  
>  &copy; IBM v1.5  2021-03-25    

## Goals  
  - Ensure business continuity while publishing new versions of API Products  
  - Control consumer subscriptions to API Products  
  - Allow API provider teams to develop and test API quickly  
  - Illustrate commands to use in DevOps
### Collateral effects   
  - Deprecate and Retire API Products gracefully  

## Prologue
This article provides sample code to implement DevOps processes described in [Governance Models & Version Control for API Products](./APIC-Pub-Sub-Version).

## <a name="Pub Sub Flow"></a> Pub Sub Flow  
The goal is to implement devops processes at scale.  
#### <a name="Simple-Scenario"></a> Simple Scenario  
- API ***api:v1*** is in Product ***product:v1*** and available to consumers through ***plan-A*** & ***plan-B***   
- Consumer applications, ***con-app-1*** & ***con-app-2*** subscribe to ***plan-A***   
- Migrate Subscriptions which belong to a single consumer organization ***con-app-2*** to ***product:v2*** and ***plan-B***   
  Consumer organizations could subscribe an application to one or more versions of same product. In addition, they could subscribe to other API products with the same application. As consumer organizations can create many applications, we could have thousands of subscriptions to a ***product:version***.

### Commands in `apic toolkit`   

When you publish a new version of a product, [Managing API Products](https://www.ibm.com/support/knowledgecenter/SSMNED_v10/com.ibm.apic.toolkit.doc/capim-toolkit-cli-manage-products.html) offers three commands which migrate all subscriptions from the source to the target product.  
- `products:replace` *retires* the old product and transfers subscriptions to the new.   
- `products:supersede`: *deprecates* the old product and transfers subscriptions to the new. You can *retire* the old product at a later date.      
- `products:set-migration-target`: allows the Provider to guide Consumer App Developers to migrate subscriptions as specified in `PRODUCT_PLAN_MAPPING_FILE`.   
- `products:execute-migration-target`: allows the Provider to migrate subscriptions which were processed by `products:set-migration-target`. Providers could preempt migration by App Developers or act on behalf of laggards.   

Another command is available, though it is not shown in [Managing API Products](https://www.ibm.com/support/knowledgecenter/SSMNED_v10/com.ibm.apic.toolkit.doc/capim-toolkit-cli-manage-products.html) as of March 2021.  
- `products:migrate-subscriptions`: allows the Provider to migrate subscriptions specified in `MIGRATE_SUBSCRIPTION_SUBSET_FILE`.

### Use Case: Migrate selected consumer organizations to the new product
Possible drivers are:
- The first few customers might be *beta* testers.
- For products with a large number of subscriptions, you could to reduce the impact of change on two fronts: split the load on API Connect and handle requests for assistance from smaller groups of business partners.   

### Sample scripts  
The following steps implement the [**Simple Scenario**](#Simple-Scenario) and migrate subscriptions using the command `products:migrate-subscriptions`. The shell scripts are in [example-toolkit-scripts/pub-sub/scripts](./scripts). The scripts illustrate the use of `apic toolkit` commands. You should modify and enhance them for use in your API Connect installations. For example, you could operate on more than one Consumer Organization in a single run or modify the commands to run within Catalog/Space.   

- [`product-subscriptions-for-corg.sh`](./scripts/product-subscriptions-for-corg.sh) Provides a CSV file with
> Consumer-Org,App-Name,Source-Product:Version,Plan-Name   

  for a given Consumer Organization and Product:Version. You can assess the inventory of subscriptions and plan operations.  
- [`products-migrate-subscriptions-1.sh`](./scripts/pub-sub/products-migrate-subscriptions-1.sh) Creates the `MIGRATE_SUBSCRIPTION_SUBSET_FILE` for a single Consumer Organization. Source & Target Products are assumed to have one for one, identically named plans. You could modify the file to alter the mapping. To effect the [Simple Scenario](#Simple-Scenario), you would modify the `MIGRATE_SUBSCRIPTION_SUBSET_FILE`:
  - From: ***product:v1*** / ***plan-A*** ==> ***product:v2*** / ***plan-A***  
  - To: ***product:v1*** / ***plan-A*** ==> to ***product:v2*** / ***plan-B***  

  Other variations are possible. For example, you could combine subscriptions from two source plans into one target plan:

  - ***product:v1*** / ***plan-A*** ==> ***product:v2*** / ***plan-B***  
  - ***product:v1*** / ***plan-B*** ==> ***product:v2*** / ***plan-B***  

  The mapping lines above are logical, easy to read statements. For the exact syntax, please see notes in `products-migrate-subscriptions-1.sh`. You must have one entry for each Source Product Plan and the Target Plans should valid.  

- [`products-migrate-subscriptions-2.sh`](./scripts/products-migrate-subscriptions-2.sh) Runs the command `products:migrate-subscriptions` on  `MIGRATE_SUBSCRIPTION_SUBSET_FILE`. The command does *not* change the lifecycle state of the Product. If the Product state was **published**, it will stay the same after the script completes.  

  > **Recommendation**: Deprecate the Source Product:Version to prevent new subscriptions. Depending on your corporate policies, you could deprecate the Source Product:Version in `products-migrate-subscriptions-1.sh` or in `products-migrate-subscriptions-2.sh`.

### Prerequisites  
- IBM API Connect experience, Linux commands
- `apic toolkit` & `jq`
- `apic login` to the management service with role which can publish Products  
- Scripts were developed and verified on IBM API Connect v10.0.1.x

### Usage  
This document and the sample scripts show what is possible with Product Versions & Consumer Subscriptions. Does it fit into your overall process?
