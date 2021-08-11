# Example Toolkit Scripts

## *hybrid-gwy* folder
- [TLS for IBM API Connect & Hybrid DataPower Gateways](./hybrid-gwy/TLS-for-Hybrid-DataPowerGateway.md): The hybrid API Gateway requires precise TLS orchestration in API Connect and DataPower.
- *hybrid-gwy* scripts implement building blocks and might be useful for DevOps oriented IBM clients. The scripts were verified on IBM API Connect (k8s) v10.0.3.

## *pub-sub* folder:  
- [Governance Models & Version Control for API Products](./pub-sub/APIC-Pub-Sub-Version.md): Perspective on versions for API Definitions & Products, version number in the API URI and the effect of Subscription Client ID in routing API calls.
- [DevOps for API Products & Consumer Subscriptions](./pub-sub/APIC-Pub-Sub-DevOps.md): Use case for migrating subscriptions which belong to a Consumer Organization and sample scripts to perform the operation.  
- *pub-sub* scripts were developed on IBM API Connect v10.0.1.x   
- Typos / Corrections: Please open github issues

## *bash* and *batch* folders:  
The scripts demonstrate the use of the toolkit commands to build and remove API Connect artifacts. These files **must** be executed in the order listed below.

- **bash** scripts run in a Unix/Linux/Cygwyn bash shell
- **batch** scripts run in a Windows command shell.

In each directory, there are two **yaml** files which define an API and Product, and a **txt** file with configuration information to create a Provider Organization admin user. Each script takes the host address of the APIC CMC instance as the first command line argument.  The **doapic-org** script takes a second argument, the CMC admin user password.

**doapic-org**:  
- Create a Provider Organization admin user  
- Create a Provider Organization  
- Configure the default sandbox catalog to use one or more gateways  

**doapic-prod**:  
- Create draft APIs and Products  
- Publish Products  
- Replace an existing published product with a new version  
- Delete a product  

**doapic-consumer**:  
- Create a Consumer Organization admin user  
- Create a Consumer Organization  
- Create a new consumer app  
- Subscribe the new app to an existing published product  

**doapic-manprod**:  
- Stages a new product version  
- Supercedes the existing published product with the new one  
- Configures subscription migration  
- Migrates existing subscriptions from the old product to the new product  

For convenience, two files undo the work performed by the others.  

**undoapic-consumer**:  
- Deletes the consumer app, thus breaking subscriptions  
- Deletes the Consumer Organization  
- Deletes the Consumer Organization admin user from the user registry  

**undoapic-org**:  
- Deletes all published products  
- Deletes the Provider Organization, thus deleting the associated catalog  
- Deletes the Provider Organization admin user from the user registry  

### Obtaining the v2018 toolkit

The scripts in *bash* and *batch* folders were developed on API Connect v2018. Please see [Working with the toolkit](https://www.ibm.com/support/knowledgecenter/en/SSMNED_2018/com.ibm.apic.toolkit.doc/capim_cli_working_with.html) for information about downloading and using the toolkit.
