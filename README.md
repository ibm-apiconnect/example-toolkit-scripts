# Example Toolkit Scripts

These scripts demonstrate how to accomplish the following tasks using the toolkit command line commands.  These files should be executed in the order listed here.

The script file named **doapic-org** performs the following tasks:

* Create a Provider Organization admin user
* Create a Provider Organization
* Configure the default sandbox catalog to use one or more gateways

The script file named **doapic-prod** performs the following tasks:

* Create draft APIs and Products
* Publish Products
* Replace an existing published product with a new version
* Delete a product

The script file named **doapic-consumer** performs the following tasks:

* Create a Consumer Organization admin user
* Create a Consumer Organization
* Create a new consumer app
* Subscribe the new app to an existing published product

The script file named **doapic-manprod** performs the following tasks:

* Stages a new product version
* Supercedes the existing published product with the new one
* Configures subscription migration
* Migrates existing subscriptions to the old product to the new product

For convenience, two files undo the work performed by the others.  These are as follows.

The script file named **undoapic-consumer** performs the following tasks:

* Deletes the consumer app, thus breaking subscriptions
* Deletes the Consumer Organization
* Deletes the Consumer Organization admin user from the user registry

The script file named **undoapic-org** performs the following tasks:

* Deletes all published products
* Deletes the Provider Organization, thus deleting the associated catalog
* Deletes the Provider Organization admin user from the user registry

## Running the scripts

You will find two versions of these scripts, one set in the **bash** directory written for the Unix/Linux/Cygwyn bash shell, and another set in the **batch** directory, written to run in a Windows command shell.

In each directory, three supporting files are included.  The two **yaml** files define an API and Product.  A **txt** file contains the configuration information needed to create a Provider Organization admin user.

Each script takes the host address of the APIC CMC instance as the first command line argument.  The **doapic-org** script takes a second command line argument, which is the CMC admin user password.

Execute these scripts in the order listed above.

 
