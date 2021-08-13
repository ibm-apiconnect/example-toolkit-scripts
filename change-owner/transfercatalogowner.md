# Transfer Catalog Owner
The Catalog Owner or an Organization Administrator can change the owner of the catalog. The new owner could be an associate in the provider org or a catalog member.
> Originally published in [pramodvallanur/samples](https://github.com/pramodvallanur/samples). Copied & edited with permission from Pramodh.

## Steps to transfer ownership to a catalog member

1. Login as the owner of the catalog to initiate the transfer
```
apic login --server apicserver
Enter your API Connect credentials
Realm? provider/default-idp-2
Username? steve
Password? *****
Logged into apicserver successfully
```

1. Get list of catalog members
```
apic members:list --scope catalog --org acme --catalog sandbox --server apicserver
jason    [state: enabled]   https://apicserver/api/catalogs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/f91c075c-1097-4ae0-99b4-1a80dadb63a2/members/9d04dc76-54a8-4e4b-89ba-dfee18eeddb9   
steve    [state: enabled]   https://apicserver/api/catalogs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/f91c075c-1097-4ae0-99b4-1a80dadb63a2/members/a35d66b7-be19-46e1-9a7a-1e129208dd22
```  
Please note the scope is important, as you can only transfer to a member already in the catalog. `steve` is the current owner of the catalog and is wanting to transfer the ownership to `jason` (jason's role within the catalog does not matter)  

1. create a json file (in my case: transferOwner.json) with the jason's catalog member url
```
{
    "new_owner_member_url": "https://apicserver/api/catalogs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/f91c075c-1097-4ae0-99b4-1a80dadb63a2/members/9d04dc76-54a8-4e4b-89ba-dfee18eeddb9",
}
```  

1. Initiate the transfer
```
apic catalogs:transfer-owner --server apicserver --org acme sandbox transferOwner.json
sandbox   https://apicserver/api/catalogs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/f91c075c-1097-4ae0-99b4-1a80dadb63a2
```  

You have now successfully transferred the ownership.

## Steps to transfer ownership to an associate in the org

1. Login as the owner of the catalog to initiate the transfer
```
apic login --server apicserver
Enter your API Connect credentials
Realm? provider/default-idp-2
Username? steve
Password? *****
Logged into apicserver successfully
```

1. Get list of associates at the org
```
apic associates:list --scope org --org acme --server apicserver
jason   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/69fb9b7c-7071-42a2-b76d-bf48f28cb04c   
steve   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/7158d40d-3983-427d-8977-294b82d6c8d8
```  
`steve` is the current owner of the catalog and is wanting to transfer the ownership to `jason` (jason's role in the catalog does not matter)  

1. Create a json file (in my case: transferOwner.json) with the jason's catalog member url
```
{
    "new_owner_associate_url": "https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/69fb9b7c-7071-42a2-b76d-bf48f28cb04c",
}
```  

1. Initiate the transfer
```
apic catalogs:transfer-owner --server apicserver --org acme sandbox transferOwner.json
sandbox   https://apicserver/api/catalogs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/f91c075c-1097-4ae0-99b4-1a80dadb63a2
```  

You have now successfully transferred the ownership.
