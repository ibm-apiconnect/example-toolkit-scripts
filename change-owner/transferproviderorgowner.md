# Transfer Org Owner
The Owner, or an Organization Administrator, can change the owner of the Organization. The new Owner could be member of the Organization or an associate. The example below details steps for a Provider Org. The same steps can be executed for the `admin` org as well.
> Originally published in [pramodvallanur/samples](https://github.com/pramodvallanur/samples). Copied & edited with permission from Pramodh.
## Steps for transferring ownership to an org member

1. Login as the owner of the org to initiate the transfer
```
apic login --server apicserver
Enter your API Connect credentials
Realm? provider/default-idp-2
Username? steve
Password? *****
Logged into apicserver successfully
```   

1. Get list of organization members
```
apic members:list --scope org --org acme --server apicserver
jason    [state: enabled]   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/members/5e2d1d36-70fd-4334-879d-df6019d69ed3   
steve    [state: enabled]   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/members/f6e80fb0-eed7-419b-a682-365a904d18eb
```  
`steve` is the current owner of the org and is wanting to transfer the ownership to `jason`

1. Create a json file (in my case: transferOwner.json) with the jason's member url
```
{
    "new_owner_member_url": "https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/members/5e2d1d36-70fd-4334-879d-df6019d69ed3",
}
```  

1. Initiate the transfer
```
apic orgs:transfer-owner --server apicserver acme transferOwner.json
acme    [state: enabled]   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c
```  

You have now successfully transferred the ownership.

## Steps for transferring ownership to an associate

1. Login as the owner of the org to initiate the transfer
```
apic login --server apicserver
Enter your API Connect credentials
Realm? provider/default-idp-2
Username? steve
Password? *****
Logged into apicserver successfully
```

1. Get list of associates of the organization
```
apic associates:list --scope org --org acme --server apicserver
jason   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/69fb9b7c-7071-42a2-b76d-bf48f28cb04c   
steve   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/7158d40d-3983-427d-8977-294b82d6c8d8
```  
`steve` is the current owner of the org and is wanting to transfer the ownership to `jason`

1. create a json file (in my case: transferOwner.json) with the jason's associate url
```
{
    "new_owner_associate_url": "https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/69fb9b7c-7071-42a2-b76d-bf48f28cb04c"
}
```  

1. Initiate the transfer
```
apic orgs:transfer-owner --server apicserver acme transferOwner.json
acme   [state: enabled]   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c
```  

You have now successfully transferred the ownership.
