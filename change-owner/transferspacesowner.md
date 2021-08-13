# Transfer Space Owner
The Space Owner or an Organization Administrator can change the owner of the space. The new owner could be an associate in the provider org or a member of the space.
> Originally published in [pramodvallanur/samples](https://github.com/pramodvallanur/samples). Copied & edited with permission from Pramodh.

## Steps for transfering ownership to a space member

1. Login as the owner of the space to initiate the transfer
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
apic members:list --scope space --server apicserver --org lob-one --catalog catalog-one --space space-one
jason    [state: enabled]   https://mystack.loki.dev.ciondemand.com/api/spaces/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/7fb311c3-21bc-43f3-bd51-da8656e62666/e0dc6c6c-7426-45c5-94e3-2c8137d687f2/members/1926bbfd-b5fb-4d7b-89f3-30e67f9a7f2c   
steve    [state: enabled]   https://mystack.loki.dev.ciondemand.com/api/spaces/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/7fb311c3-21bc-43f3-bd51-da8656e62666/e0dc6c6c-7426-45c5-94e3-2c8137d687f2/members/5a845fcc-49b3-4e06-9aa0-369c3bfaf3bc
```  
Please note the scope is important, as you can only transfer to a member already in the `space`. `steve` is the current owner of the space and is wanting to transfer the ownership to `jason` (jason's role within the space does not matter)  

1. create a json file (in my case: transferOwner.json) with the jason's space member url
```
{
    "new_owner_member_url": "https://apicserver/api/spaces/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/7fb311c3-21bc-43f3-bd51-da8656e62666/e0dc6c6c-7426-45c5-94e3-2c8137d687f2/members/1926bbfd-b5fb-4d7b-89f3-30e67f9a7f2c",
}
```  

1. Initiate the transfer
```
apic spaces:transfer-owner --server apicserver --org lob-one --catalog catalog-one space-one transferOwner.json
space-one   https://apicserver/api/spaces/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/7fb311c3-21bc-43f3-bd51-da8656e62666/d1245d4c-2308-488f-92b9-f6198f2d9115
```  

You have now successfully transferred the ownership.

## Steps for transfering ownership to an associate in the org

1. Login as the owner of the space to initiate the transfer
```
apic login --server apicserver
Enter your API Connect credentials
Realm? provider/default-idp-2
Username? steve
Password? *****
Logged into apicserver successfully
```

1. Get list of associates of the org
```
apic associates:list --scope org --org acme --server apicserver
jason   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/69fb9b7c-7071-42a2-b76d-bf48f28cb04c   
steve   https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/7158d40d-3983-427d-8977-294b82d6c8d8
```  
`steve` is the current owner of the space and is wanting to transfer the ownership to `jason` (jason's role in the catalog does not matter)  

1. Create a json file (in my case: transferOwner.json) with the jason's catalog member url
```
{
    "new_owner_associate_url": "https://apicserver/api/orgs/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/associates/69fb9b7c-7071-42a2-b76d-bf48f28cb04c",
}
```  

1. Initiate the transfer
```
apic spaces:transfer-owner --server apicserver --org lob-one --catalog catalog-one space-one transferOwner.json
space-one   https://apicserver/api/spaces/5f9fba35-a5d9-46ea-ae57-6c1d7324133c/7fb311c3-21bc-43f3-bd51-da8656e62666/d1245d4c-2308-488f-92b9-f6198f2d9115
```  

You have now successfully transferred the ownership.
