echo off
setlocal
set server=%1
set user=admin
set password=%2
set user_file=user-steve.txt
set porg_name=shellorg


for /F "tokens=1,2 delims= " %%a in (%user_file%) do (
if %%a==username: (
set new-user=%%b )
if %%a==password: (
set new-user-password=%%b )
)

echo logging in as provider org admin 
apic login --server %server% --username %new-user% --password %new-user-password% --realm provider/default-idp-2

timeout /t 2 /nobreak > NUL
echo               :


echo remove all products - may be none
apic products:clear-all --server %server% --org %porg_name% --catalog sandbox --scope catalog --confirm sandbox
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog

echo log out as provider admin
apic logout --server %server%

echo               :
echo log in as CMC admin
apic login --server %server% --username %user% --password %password% --realm admin/default-idp-1

timeout /t 2 /nobreak > NUL

echo               :
echo delete provider org - long delay
apic orgs:delete --server %server% %porg_name%

timeout /t 3 /nobreak > NUL
echo               :

echo delete Provider org admin user
apic users:delete --server %server% --org admin --user-registry api-manager-lur %new-user%

echo               :

echo work done log out as cmc admin
apic logout --server %server%


