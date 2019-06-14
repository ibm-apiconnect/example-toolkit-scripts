echo off
setlocal
set server=%1
set user=steve
set password=Passw0rd
set porg_name=steveorg
set api_file=findbrancha.yaml
set prod_file=brancha_prod.yaml

echo log in as Provider Org owner
apic login --server %server% --username %user% --password %password% --realm provider/default-idp-2

timeout /t 3 /nobreak > NUL
echo        :

echo identify the product to supercede
set ACMD=apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog 
for /f "tokens=1,2,3,4 delims= " %%a in ('%ACMD%') do (
set gURL=%%d
echo %%a %gURL%)
echo        :
set product_url=product_url: %gURL%
echo %product_url% > supersede.txt

echo build supercede map
echo plans: >> supersede.txt
echo - source: default >> supersede.txt
echo   target: default >> supersede.txt
type supersede.txt
echo        :

echo check subscriptions to existing prod
apic subscriptions:list --server %server% --org %porg_name% --catalog sandbox --consumer-org eights --app blackball
echo        :

echo create and stage a superceding product
rem capture product url for later use
set ACMD=apic products:publish --server %server% --org %porg_name% --catalog sandbox --stage brancha_prod.yaml 
for /f "tokens=1,2,3,4 delims= " %%a in ('%ACMD%') do set gURL=%%d
set product_url=product_url: %gURL%
echo %product_url% > migrate.txt

echo product list note staged
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog
echo        :

echo supercede existing product
apic products:supersede --server %server% --org %porg_name% --catalog sandbox --scope catalog findbrancha:1.0.0 supersede.txt
echo        :

echo product states
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog 
echo        :

echo subscription states
set ACMD=apic subscriptions:list --server %server% --org %porg_name% --catalog sandbox --consumer-org eights --app blackball
for /f "tokens=1 delims= " %%a in ('%ACMD%') do set sb=%%a
echo subscription id %sb%
echo        :

rem get a copy of the subscription yaml
apic subscriptions:get --server %server% --org %porg_name% --catalog sandbox --consumer-org eights --app blackball %sb%>nul

echo show subscription details examine product url

set sb_file=%sb%.yaml
for /F "delims=" %%i in (%sb_file%) do (
    echo "%%i" | findstr /C:"updated">nul && (
    goto :eof
) || (
    echo.%%i
)
)
echo        :


echo build migration target file
echo plans: >> migrate.txt
echo - source: default >> migrate.txt
echo   target: default >> migrate.txt
type migrate.txt
echo        :

echo set migration target
apic products:set-migration-target --server %server% --org %porg_name% --catalog sandbox --scope catalog findbrancha:2.0.0 migrate.txt
echo        :

echo migrate subscriptions
apic products:execute-migration-target --server %server% --org %porg_name% --catalog sandbox --scope catalog findbrancha:2.0.0
echo        :

echo subscription states
set ACMD=apic subscriptions:list --server %server% --org %porg_name% --catalog sandbox --consumer-org eights --app blackball
for /f "tokens=1,2,3,4 delims= " %%a in ('%ACMD%') do set sb=%%a
echo subscription id %sb%
echo        :

echo show subscription details examine product url
apic subscriptions:get --server %server% --org %porg_name% --catalog sandbox --consumer-org eights --app blackball --output - %sb%

echo work done
apic logout --server %server%

