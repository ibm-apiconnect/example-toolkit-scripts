echo off
setlocal
set server=%1
set user=steve
set password=Passw0rd
set porg_name=steveorg
set api_file=findbrancha.yaml
set prod_file=brancha_prod.yaml

echo log into provider org
apic login --server %server% --username %user% --password %password% --realm provider/default-idp-2
timeout /t 1 /nobreak > NUL

echo remove app in consumer org
apic apps:delete --server %server% --org %porg_name% --consumer-org eights --catalog sandbox blackball

echo delete consumer org
apic consumer-orgs:delete --server %server% --org %porg_name% --catalog sandbox eights
timeout /t 3 /nobreak > NUL
echo       :   

echo remove consumer user
apic users:delete --server %server% --org %porg_name% --user-registry sandbox-catalog eighter

echo work done
apic logout --server %server% 
