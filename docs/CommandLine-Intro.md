# IBM API Connect
> ## v10 Command Line - Introduction    
>  Ravi Ramnarayan  
>  &copy; IBM v0.75  2022-01-24  

This is gist of **lessons learned** from my struggles with the `apic-slim` command. I found it difficult to get started. Once I realized that the installer created the `admin` Organization, Scope & Realm, progress was much smoother. After that I introduce a few commands and steps to extract data to support automation scripts.  


After installation:  
- Log into the Cloud Manager Console (CMC) as `admin`
- Set password & email address for `admin` through the GUI  
  Yes, you could do it via command line. Trust me. Use the GUI.  
- Push the tile **Download toolkit** and download the "CLI Only" for your platform along with the `client-creds`

> ***Note***: I renamed `apic-slim` to `apic` for simplicity.

## Get started with command line
Each user belongs to a `realm` and authenticates with an `identity-provider`. To log in, even the `admin` needs to provide the name of the `identity-provider`. How can I find the name of the `identity-provider` if I cannot login? There is a way out. CMC objects belong to the `admin` scope. This command works without login:

```
  $ ./apic identity-providers:list --scope admin --server platform.mgmt.dev.apic.xxxxx.test --fields name,title
  total_results: 1
  results:
    - name: default-idp-1
      title: Cloud Manager User Registry
```
> ***Note***: Your endpoints might be different.

Log in as `admin`:  
```
  $ ./apic login
  Enter your API Connect credentials
  Server? apim.mgmt.dev.apic.xxxxx.test
  Realm? admin/default-idp-1
  Username? admin
  Password?
```  

At this stage there is only one *Organization*:  
```
$ ./apic orgs:list  -s apim.mgmt.dev.apic.xxxxx.test --format yaml
total_results: 1
results:
  - type: org
    api_version: 2.0.0
    id: 790cbfc3-fafc-489e-a2fe-d7e827cea731
    name: admin
    title: Cloud Admin
    summary: Cloud Admin organization
    state: enabled
    org_type: admin
    owner_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/user-registries/790cbfc3-fafc-489e-a2fe-d7e827cea731/7218cc7f-4ac9-4f0a-992c-53ec31eb032e/users/6037d730-4218-4ed2-8e03-1aa596d34671
    created_at: '2020-07-21T14:15:19.160Z'
    updated_at: '2020-07-21T14:15:19.160Z'
    url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731
```
The output for just one `org` is voluminous. Other objects emit far more data. You can generate JSON with `--format json`, pipe it through `jq` and extract desired elements to feed your automated scripts.   
```
$ ./apic orgs:list  -s apim.mgmt.dev.apic.xxxxx.test --format json | jq '.results[0] | {name: .name, org_type: .org_type, summary: .summary, id: .id}'
{
  "name": "admin",
  "org_type": "admin",
  "summary": "Cloud Admin organization",
  "id": "790cbfc3-fafc-489e-a2fe-d7e827cea731"
}
```
[JQ Tutorial](https://stedolan.github.io/jq/tutorial/) is an excellent reference.  

## Resources  
### Email Server  
Create the mail server through the GUI. Too much work to do so via command line. Enable *Secure Connection* and select *Default TLS client profile*.
  ```
  $ ./apic cloud-settings:mail-server-configured -s apim.mgmt.dev.apic.xxxxx.test --format yaml
  configured: true
  ```
  If you wish to modify settings using the `apic` toolkit or through REST API, retrieve the mail server settings in a file, make changes and update the mail server.   
  ```
  $ ./apic mail-servers:list -s apim.mgmt.dev.apic.xxxxx.test -o admin --format json
  {
      "total_results": 1,
      "results": [
          {
              "type": "mail_server",
              "api_version": "2.0.0",
              "id": "97a1b1e9-e65a-4147-869b-a66b996ec022",
              "name": "ibm-lab-mail",
              "title": "IBM Lab Mail",
              "host": "mail.xxxxx.test",
              "port": 25,
              "credentials": {},
              "timeout": 10000,
              "secure": true,
              "tls_client_profile_url": "https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/tls-client-profiles/e6af6dad-caf5-4ac2-9764-6eec79b0c934",
              "created_at": "2020-07-22T21:18:35.189Z",
              "updated_at": "2020-07-22T21:20:37.756Z",
              "url": "https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/mail-servers/97a1b1e9-e65a-4147-869b-a66b996ec022"
          }
      ]
  }
  ```
  You can filter the JSON:  
  ```
  $ ./apic mail-servers:list -s apim.mgmt.dev.apic.xxxxx.test -o admin --format json | jq '.results[0] | {name: .name, type: .type, host: .host, port: .port, id: .id}'
  {
    "name": "ibm-lab-mail",
    "type": "mail_server",
    "host": "mail.xxxxx.test",
    "port": 25,
    "id": "97a1b1e9-e65a-4147-869b-a66b996ec022"
  }
  ```

### User Registries  
Create a user registry, LDAP in this case, using the GUI. Capture the settings for documentation and automation in the future. Play with the commands and options to develop your style. The examples below illustrate four variations of `user-registries`.   
- Short list of user registries
  > **Note**: Use `-o admin` to list all user registries.  

  ```
    $ ./apic user-registries:list -s apim.mgmt.dev.apic.xxxxx.test -o admin
    api-manager-lur     https://apim.mgmt.dev.apic.xxxxx.test/api/user-registries/790cbfc3-fafc-489e-a2fe-d7e827cea731/9d96be5b-02c5-4802-a8ed-ca23c241f150   
    cloud-manager-lur   https://apim.mgmt.dev.apic.xxxxx.test/api/user-registries/790cbfc3-fafc-489e-a2fe-d7e827cea731/7218cc7f-4ac9-4f0a-992c-53ec31eb032e   
    ibm-lab-ldap        https://apim.mgmt.dev.apic.xxxxx.test/api/user-registries/790cbfc3-fafc-489e-a2fe-d7e827cea731/65b6dc90-1ac4-4145-8d3d-d1cad499bb95   
  ```

- Capture setting for `ibm-lab-ldap` in a file `ibm-lab-ldap.yaml` in the current directory
  ```
    $ ./apic user-registries:get -s apim.mgmt.dev.apic.xxxxx.test -o admin ibm-lab-ldap --format yaml
  ```
- Dump settings for `ibm-lab-ldap` to the console
  ```
    $ ./apic user-registries:get -s apim.mgmt.dev.apic.xxxxx.test -o admin ibm-lab-ldap --format yaml --output -
    type: user_registry
    api_version: 2.0.0
    id: 65b6dc90-1ac4-4145-8d3d-d1cad499bb95
    name: ibm-lab-ldap
    title: IBM Lab LDAP
    integration_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/cloud/integrations/user-registry/5f52edfd-64bf-447c-a6b2-cd675c39c37b
    registry_type: ldap
    user_managed: false
    user_registry_managed: false
    case_sensitive: false
    identity_providers:
      - name: ibm-lab-ldap
        title: IBM Lab LDAP
    visibility:
      type: public
    configuration:
      attribute_mapping: {}
      authenticated_bind: 'false'
      authentication_method: search_dn
      protocol_version: '3'
      search_dn_base: 'ou=Users,dc=ibmlab,dc=test'
      search_dn_filter_prefix: (uid=
      search_dn_filter_suffix: )
    endpoint:
      endpoint: 'ldap://ldap.xxxxx.test:389'
    owned: true
    created_at: '2020-07-22T22:08:05.567Z'
    updated_at: '2020-07-22T22:08:05.567Z'
    org_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731
    url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/user-registries/790cbfc3-fafc-489e-a2fe-d7e827cea731/65b6dc90-1ac4-4145-8d3d-d1cad499bb95
  ```

- Details of user registries   
  Play around with commands and options. The `list` command with `--format json` provides details. The example below filters the data and returns it as an array.

  ```
  $ ./apic user-registries:list -s apim.mgmt.dev.apic.xxxxx.test -o admin --format json | jq '[.results[] | { name: .name, registry_type: .registry_type, visibility: .visibility.type, id: .id }]'
  [
    {
      "name": "api-manager-lur",
      "registry_type": "lur",
      "visibility": "private",
      "id": "9d96be5b-02c5-4802-a8ed-ca23c241f150"
    },
    {
      "name": "cloud-manager-lur",
      "registry_type": "lur",
      "visibility": "private",
      "id": "7218cc7f-4ac9-4f0a-992c-53ec31eb032e"
    },
    {
      "name": "ibm-lab-ldap",
      "registry_type": "ldap",
      "visibility": "public",
      "id": "65b6dc90-1ac4-4145-8d3d-d1cad499bb95"
    }
  ]
  ```

## Topology

### Cloud topology snapshot
[ChrisPhillips-cminion/APIConnect-Profiler](https://github.com/ChrisPhillips-cminion/APIConnect-Profiler) provides a snapshot of your API Connect solution comprising Provider Organizations, Catalogs with associated Consumer Organizations, and operational aspects such as webhooks. If you want a different set of information, you can follow steps in [Extract topology data for automation](#Extract-topology-data-for-automation).  

### Management Service
The installer creates the *default* Availability Zone and a Management Service. Almost all installations will use only one Availability Zone with one Management Service.  
```
$ ./apic availability-zones:list -s apim.mgmt.dev.apic.xxxxx.test -o admin --format json | jq '.results[0] | {name: .name, type: .type, management: .management, id: .id}'
{
  "name": "availability-zone-default",
  "type": "availability_zone",
  "management": true,
  "id": "311ca835-766d-45fb-ad69-daaf2404d654"
}
```

### Gateway Service  [⇡](#Cloud-topology-for-governance)
Define Gateway Services in the CMC console.

```
$ ./apic gateway-services:list --availability-zone availability-zone-default -o admin -s apim.mgmt.dev.apic.xxxxx.test --format yaml
total_results: 1
results:
  - type: gateway_service
    api_version: 2.0.0
    id: f84a3961-17da-4ca5-8b63-afe212c41459
    name: apigw
    title: apigw
    integration_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/cloud/integrations/gateway-service/345a1dc9-3f75-4931-8dde-9dc2954b4958
    gateway_service_type: datapower-api-gateway
    endpoint: 'https://service.gw.dev.apic.xxxxx.test'
    api_endpoint_base: 'https://api.gw.dev.apic.xxxxx.test'
    tls_client_profile_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/tls-client-profiles/e6af6dad-caf5-4ac2-9764-6eec79b0c934
    sni:
      - host: '*'
        tls_server_profile_url: >-
          https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/tls-server-profiles/91d93b6b-e36a-41e6-905c-d20326a3032b
    oauth_shared_secret: '********'
    visibility:
      type: public
    owned: true
    configuration:
      domain_name: apiconnect
      gateway_version: 6.0.0.0
      managed_by: apim
    analytics_service_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654/analytics-services/60f54cb3-e903-430d-a6fd-102953976ffe
    webhook_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/cloud/webhooks/061611de-9e39-4793-8994-759e591a5dd6
    availability_zone_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654
    created_at: '2020-08-03T22:01:53.044Z'
    updated_at: '2020-08-03T22:12:19.889Z'
    org_url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731
    url: >-
      https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654/gateway-services/f84a3961-17da-4ca5-8b63-afe212c41459

```
### Analytic Services  
  ```
  $ ./apic analytics-services:list --availability-zone availability-zone-default -o admin -s apim.mgmt.dev.apic.xxxxx.test --format yaml
  total_results: 1
  results:
    - type: analytics_service
      api_version: 2.0.0
      id: 60f54cb3-e903-430d-a6fd-102953976ffe
      name: analytics
      title: Analytics
      endpoint: 'https://client.analytics.dev.apic.xxxxx.test'
      ingestion_endpoint: 'https://ingestion.analytics.dev.apic.xxxxx.test'
      ingestion_endpoint_tls_client_profile_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/tls-client-profiles/41baf21b-27a0-4a1b-a846-8bdc1593b1a7
      client_endpoint: 'https://client.analytics.dev.apic.xxxxx.test'
      client_endpoint_tls_client_profile_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/tls-client-profiles/35446fca-4588-4590-b1a3-147d8a842f7a
      availability_zone_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654
      created_at: '2020-08-03T22:10:28.131Z'
      updated_at: '2020-08-03T22:10:28.131Z'
      org_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654/analytics-services/60f54cb3-e903-430d-a6fd-102953976ffe
  ```
### Portal Services  
  ```
  $ ./apic portal-services:list --availability-zone availability-zone-default -o admin -s apim.mgmt.dev.apic.xxxxx.test --format yaml
  total_results: 1
  results:
    - type: portal_service
      api_version: 2.0.0
      id: 2cdf182d-71c2-40a3-9374-d05c31f2512e
      name: portal
      title: Portal
      web_endpoint_base: 'https://portal.dev.apic.xxxxx.test'
      endpoint: 'https://api.portal.dev.apic.xxxxx.test'
      endpoint_tls_client_profile_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/tls-client-profiles/20195467-f5c4-411a-b440-46c1669d2d36
      visibility:
        type: public
      owned: true
      webhook_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/cloud/webhooks/237498d0-bcd1-41a3-bbb8-99be3500a351
      availability_zone_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654
      created_at: '2020-08-03T22:11:46.957Z'
      updated_at: '2020-08-03T22:11:48.246Z'
      org_url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731/availability-zones/311ca835-766d-45fb-ad69-daaf2404d654/portal-services/2cdf182d-71c2-40a3-9374-d05c31f2512e
  ```

### Extract topology data for automation
The full dump yields two sub documents **counts** and **orgs**:
```
$ ./apic cloud-settings:topology -s apim.mgmt.dev.apic.xxxxx.test --format json  
{
  "counts": {
    "users": 1,
    "provider_orgs": 0,
    "catalogs": 0,
    "draft_products": 0,
    "draft_apis": 0,
    "apis": 0,
    "products": 0,
    "consumer_orgs": 0,
    "subscriptions": 0
    },
    "orgs": {
      "total_results": 1,
      "results": [
      {
        "id": "790cbfc3-fafc-489e-a2fe-d7e827cea731",
        "name": "admin",
        "title": "Cloud Admin",
        "summary": "Cloud Admin organization",
        "state": "enabled",
        "org_type": "admin",
        "owner_url": "https://apim.mgmt.dev.apic.xxxxx.test/api/user-registries/790cbfc3-fafc-489e-a2fe-d7e827cea731/7218cc7f-4ac9-4f0a-992c-53ec31eb032e/users/6037d730-4218-4ed2-8e03-1aa596d34671",
        "owner": {
          "email": "boromir@ibmlab.test",
          "first_name": "Cloud",
          "last_name": "Owner"
          },
          "counts": {
            "members": 1
            },
            "url": "https://apim.mgmt.dev.apic.xxxxx.test/api/orgs/790cbfc3-fafc-489e-a2fe-d7e827cea731"
          }
          ]
        }
      }
```
  Extract fields from **counts**
  ```
  $ ./apic cloud-settings:topology -s apim.mgmt.dev.apic.xxxxx.test --format json | jq '[{ users: .counts.users, provider_orgs: .counts.provider_orgs, catalogs: .counts.catalogs, draft_products: .counts.draft_products, draft_apis: .counts.draft_apis, apis: .counts.apis, products: .counts.products, consumer_orgs: .counts.consumer_orgs, subscriptions: .counts.subscriptions } ]'
  [
  {
    "users": 1,
    "provider_orgs": 0,
    "catalogs": 0,
    "draft_products": 0,
    "draft_apis": 0,
    "apis": 0,
    "products": 0,
    "consumer_orgs": 0,
    "subscriptions": 0
  }
  ]
  ```
  Extract fields from **orgs**:  
  ```
  $ ./apic cloud-settings:topology -s apim.mgmt.dev.apic.xxxxx.test --format json | jq '[ .orgs.results[] | { name: .name, title: .title, state: .state, org_type: .org_type, id: .id, owner_email: .owner.email, counts_members: .counts.members } ]'
  [
  {
    "name": "admin",
    "title": "Cloud Admin",
    "state": "enabled",
    "org_type": "admin",
    "id": "790cbfc3-fafc-489e-a2fe-d7e827cea731",
    "owner_email": "boromir@ibmlab.test",
    "counts_members": 1
  }
  ]
  ```

## Add User to a Catalog  
The member invitation request comprises the member's name & email address, roles, provider organization and catalog name.

> **Note**: In this example, the *Scope* is *Catalog*. Parameters such as *Role* should be valid within the scope.  

An example with mock data drawn from
```
{
  "name": "Alice Wells",
  "scope": "jucavunohbu",
  "notify": true,
  "email": "mannuf@opa.gu",
  "org_type": "zoruhjadomow",
  "role_urls": [
    "http://cono.pm/keljihzu",
    "http://nivpuraw.cg/lo",
    "http://fasfo.la/mucojo"
  ],
  "expires_at": "2020-01-22T05:36:15.888Z",
  "org_url": "http://jiweif.cr/da",
  "catalog_url": "http://wa.gq/kogzoces",
}
```

- User Roles within Scope  

  ```
  ./apic roles:list -s apim.mgmt.dev.apic.xxxxx.test --scope catalog -o porg1 -c p1cat-a --fields name,id,url
  total_results: 7
  results:
    - name: administrator
      id: a01cef65-051c-4ed8-a11d-ef35170f4779
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/a01cef65-051c-4ed8-a11d-ef35170f4779
    - name: api-administrator
      id: 2f18c12d-b5c9-4fd2-abdb-24c37bb52463
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/2f18c12d-b5c9-4fd2-abdb-24c37bb52463
    - name: community-manager
      id: 668dc36f-7d48-4982-8dcc-4ede5aa9cc42
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/668dc36f-7d48-4982-8dcc-4ede5aa9cc42
    - name: developer
      id: dbf34782-2ab8-4730-b90f-d1ee1d851198
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/dbf34782-2ab8-4730-b90f-d1ee1d851198
    - name: member
      id: 1ef19174-49ac-4948-8eb7-6cef6efb22df
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/1ef19174-49ac-4948-8eb7-6cef6efb22df
    - name: owner
      id: afd6e4eb-ae53-49cc-bf50-bf6bf0e9a9d0
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/afd6e4eb-ae53-49cc-bf50-bf6bf0e9a9d0
    - name: viewer
      id: 965e2b0f-4a86-481d-83f7-9559cd635ae4
      url: >-
        https://apim.mgmt.dev.apic.xxxxx.test/api/catalogs/1c8769ad-b8a6-41a0-9356-71135f5e28e0/b4fd469b-f25a-4c57-9242-8571cfa7d650/roles/965e2b0f-4a86-481d-83f7-9559cd635ae4
  ```
