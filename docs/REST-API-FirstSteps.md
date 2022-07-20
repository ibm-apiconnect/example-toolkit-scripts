# IBM API Connect  
> ## v10 REST API: First Steps  
>  Ravi Ramnarayan, Eric Fan    
>  &copy; IBM v0.8  2022-07-20   

## Goal
- Open the doors to [APIConnect REST API](https://apic-api.apiconnect.ibmcloud.com/v10/)  


### List *Provider* Identity  Providers  

`$ curl -k -H "Accept: application/json" https://platform.mgmt.dev.apic.xxxxx.xxx/api/cloud/provider/identity-providers`
```
{
    "total_results": 2,
    "results": [
        {
            "name": "default-idp-2",
            "title": "API Manager User Registry",
            "default": false,
            "registry_type": "lur",
            "user_managed": true,
            "realm": "provider/default-idp-2"
        },
        {
            "name": "ibm-lab-ldap",
            "title": "IBM Lab LDAP",
            "default": true,
            "registry_type": "ldap",
            "user_managed": false,
            "realm": "provider/ibm-lab-ldap"
        }
    ]
}

```
> ***Note***: Your endpoints might be different.


### Create Consumer Application  
Log into API Connect CLI as user with (adequate) `admin` privileges.  

- Input file  
  ```
  $ cat myapp1.json
  {
    "name": "myapp1",
    "client_id": "myapp1id",
    "client_secret": "myapp1secret",
    "client_type": "toolkit"
  }  
```  

  Why did we use `"client_type": "toolkit"`? Run the following command to list the complete set:  
  `$ apic registrations:list -s platform.mgmt.dev.apic.xxxxx.xxx`  

- Command  
  `apic registrations:create --server apim.mgmt.dev.apic.xxxxx.xxx myapp1.json`
  `myapp1    [state: enabled]   https://platform.mgmt.dev.apic.xxxxx.xxx/api/cloud/registrations/dec850ab-7b73-48b0-ad08-adde3da12d14`  

- Get `myapp1`  
`$ apic registrations:get -s platform.mgmt.dev.apic.xxxxx.xxx myapp1`  
`myapp1   myapp1.yaml   https://platform.mgmt.dev.apic.xxxxx.xxx/api/cloud/registrations/dec850ab-7b73-48b0-ad08-adde3da12d14 `  

- Examine `myapp1.yaml`  

  ```  
  $ cat myapp1.yaml  
  type: registration  
  api_version: 2.0.0  
  id: dec850ab-7b73-48b0-ad08-adde3da12d14  
  name: myapp1  
  title: myapp1  
  state: enabled  
  client_type: toolkit  
  client_id: myapp1id  
  client_secret: '********'  
  scopes:  
    - 'cloud:view'  
    - 'cloud:manage'  
    - 'provider-org:view'  
    - 'provider-org:manage'  
    - 'org:view'  
    - 'org:manage'  
    - 'product-drafts:view'  
    - 'product-drafts:edit'  
    - 'api-drafts:view'  
    - 'api-drafts:edit'  
    - 'child:view'  
    - 'child:create'  
    - 'child:manage'  
    - 'product:view'  
    - 'product:stage'  
    - 'product:manage'  
    - 'approval:view'  
    - 'approval:manage'  
    - 'api-analytics:view'  
    - 'api-analytics:manage'  
    - 'consumer-org:view'  
    - 'consumer-org:manage'  
    - 'app:view:all'  
    - 'app:manage:all'  
    - 'my:view'  
    - 'my:manage'  
    - 'webhook:view'  
  created_at: '2021-11-19T17:44:39.000Z'  
  updated_at: '2021-11-19T17:44:39.000Z'  
  url: >-  
    https://platform.mgmt.dev.apic.xxxxx.xxx/api/cloud/registrations/dec850ab-7b73-48b0-ad08-adde3da12d14  
  ```    

### Generate API Token  
To REST. At last.

  `curl -v -k -X POST -d '{"username": "fbaggins", "password": "********", "realm": "provider/ibm-lab-ldap", "client_id": "myapp1id", "client_secret": "myapp1secret", "grant_type": "password"}' -H 'Content-Type: application/json' -H 'Accept: application/json' https://platform.mgmt.dev.apic.xxxxx.xxx/api/token`  

  ```  
  {  
      "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXV ... XXXX ... al6lQFV4UeiG_88gO6j7q_MQ",  
      "token_type": "Bearer",  
      "expires_in": 28800  
  * Connection #0 to host platform.mgmt.dev.apic.xxxxx.xxx left intact  
  }  
  ```  

### Retrieve `ibm-lab-ldap` Users  
Use the token to make REST API calls within the scope of application `myapp1`.  


`$ curl -k --request GET \
  --url 'https://platform.mgmt.dev.apic.xxxxx.xxx/api/user-registries/p1org/ibm-lab-ldap/users?fields=name' --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXV ... XXXX ... al6lQFV4UeiG_88gO6j7q_MQ' --header 'accept: application/json'`  

There is only one user in this registry.   

  ```  
{  
    "total_results": 1,  
    "results": [  
        {  
            "name": "fbaggins"  
        }  
    ]  
}  
```  
