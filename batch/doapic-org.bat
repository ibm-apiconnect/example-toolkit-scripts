echo off
setlocal
set server=%1
set user=admin
set password=%2
set user_file=user-steve.txt
set porg_name=steveorg
set api_file=findbrancha.yaml
set prod_file=brancha_prod.yaml

rem Create provider org file stub
echo name: %porg_name%>%porg_name%.txt
echo title: %porg_name%>>%porg_name%.txt

echo log in as CMC admin
apic login --server %server% --username %user% --password %password% --realm admin/default-idp-1

timeout /t 2 /nobreak > NUL

echo               :
echo create new Provider org admin user and create org file

set ACMD="apic users:create --server %server% --org admin --user-registry api-manager-lur "%user_file%
for /f "tokens=4 delims= " %%a in ('%ACMD%') do set URL=%%a
set owner_url=owner_url: %URL%
echo %owner_url% >> %porg_name%.txt
type %porg_name%.txt

echo               :
echo create new Provider org
apic orgs:create --server %server% %porg_name%.txt

timeout /t 4 /nobreak > NUL
echo               :

echo log out as cmc admin
apic logout --server %server%

timeout /t 2 /nobreak > NUL
echo               :

for /F "tokens=1,2 delims= " %%a in (%user_file%) do (
if %%a==username: (
set new-user=%%b )
if %%a==password: (
set new-user-password=%%b )
)

echo logging in as provider org username %new-user% password %new-user-password%
apic login --server %server% --username %new-user% --password %new-user-password% --realm provider/default-idp-2

timeout /t 2 /nobreak > NUL
echo               :

setlocal ENABLEDELAYEDEXPANSION
echo list available gateway(s) for sandbox catalog
set ACMD=apic gateway-services:list --server %server% --org %porg_name% --scope org 
set count=0
for /f "tokens=2 delims= " %%a in ('%ACMD%') do (
      set gURL=%%a
	set /a count=count+1
echo.!gURL!
	set gateway_url=gateway_service_url: !gURL!
    echo !gateway_url! > gwsvc!count!.txt
)

echo there are !count! gateway services
echo               :

echo configure gateway(s) for sandbox catalog
set /a i = 1 
:loop 

if !i! leq !count! (
apic configured-gateway-services:create --server %server% --org %porg_name% --scope catalog --catalog sandbox gwsvc!i!.txt
set /a i=!i!+1 
goto :loop 
)
endlocal

echo               :
echo work complete log out
apic logout --server %server%




