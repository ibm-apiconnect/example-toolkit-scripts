echo off
setlocal
set server=%1
set user=steve
set password=Passw0rd
set user_file=user-steve.txt
set porg_name=steveorg
set api_file=findbrancha.yaml
set prod_file=brancha_prod.yaml

apic login --server %server% --username %user% --password %password% --realm provider/default-idp-2
timeout /t 3 /nobreak > NUL

echo Current draft apis:
apic draft-apis:list-all --server %server% --org %porg_name%
echo Current draft products:
apic draft-products:list-all --server %server% --org %porg_name%
echo        :
echo create new draft prod
apic draft-products:create --server %server% --org %porg_name% brancha_prod.yaml
echo        :
echo publish same draft prod
echo        :

rem capture product url for use in replace map
set ACMD=apic products:publish --server %server% --org %porg_name% --catalog sandbox brancha_prod.yaml
for /f "tokens=4 delims= " %%a in ('%ACMD%') do set gURL=%%a
set product_url=product_url: %gURL%
echo %product_url%>prodmap.txt
echo plans:>>prodmap.txt
echo - source: default>>prodmap.txt
echo   target: default>>prodmap.txt

echo Published product list
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog
echo        :

rem create new api and prod yaml locally
rem first make sure file doesn't exist
del findbrancha2.yaml
del brancha_prod2.yaml
for /F "delims=" %%i in (%api_file%) do (
    echo "%%i" | findstr /C:"version: 1">nul && (
    echo   version: 2.0.0 >> findbrancha2.yaml
) || (
    echo.%%i >> findbrancha2.yaml
)
)

for /F "delims=" %%i in (%prod_file%) do (
echo "%%i" | findstr /C:"version: 1">nul && (
    echo   version: 2.0.0 >> brancha_prod2.yaml
) || (
    echo "%%i" | findstr /C:"findbrancha.yaml">nul && ( 
	echo     $ref: findbrancha2.yaml>>brancha_prod2.yaml )
	) || (
    echo.%%i >> brancha_prod2.yaml
)
)

echo stage new  version of product
apic products:publish --server %server% --org %porg_name% --catalog sandbox --stage brancha_prod2.yaml
timeout /t 2 /nobreak > NUL
echo        :

echo list all products in catalog - note staged
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog
echo        :

echo replace published with staged product
apic products:replace --server %server% --org %porg_name% --scope catalog --catalog sandbox findbrancha:2.0.0 prodmap.txt
timeout /t 1 /nobreak > NUL
echo        :

echo list all products in catalog - note state
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog
echo        :

echo delete retired product
apic products:delete --server %server% --org %porg_name% --scope catalog --catalog sandbox findbrancha:1.0.0
echo        :

echo list products
apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog
echo        :

echo work done
apic logout --server %server% 