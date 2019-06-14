echo off
setlocal
set server=qa1042.argo2-sl.dev.ciondemand.com
set user=steve
set password=Passw0rd
set porg_name=steveorg


rem build consumer user file
echo username: eighter>user-eighter.txt
echo email: eighter@example.com>>user-eighter.txt
echo first_name: Eighter>>user-eighter.txt
echo last_name: Decatur>>user-eighter.txt
echo password: Passw0rd>>user-eighter.txt

echo here is the consumer org owner
echo        :
cat user-eighter.txt
echo        :
echo name: eights>eights-org.txt
echo title: Eight Balls>>eights-org.txt


echo log into provider org
apic login --server %server% --username %user% --password %password% --realm provider/default-idp-2
timeout /t 1 /nobreak > NUL

echo        :
echo create new catalog user

set ACMD=apic users:create --server %server% --org %porg_name% --user-registry sandbox-catalog user-eighter.txt
for /f "tokens=4 delims= " %%a in ('%ACMD%') do set URL=%%a
set owner_url=owner_url: %URL%
echo %owner_url% >>eights-org.txt
echo        :
echo new consumer org file
type eights-org.txt
echo        :

echo create new consumer org

apic consumer-orgs:create --server %server% --org %porg_name% --catalog sandbox eights-org.txt
timeout /t 1 /nobreak > NUL
echo        :

rem create app file
echo title: blackball>black-app.txt
echo Create new app in new consumer org
apic apps:create --server %server% --org %porg_name% --consumer-org eights --catalog sandbox black-app.txt
echo        :

echo create subscription file
set ACMD=apic products:list-all --server %server% --org %porg_name% --catalog sandbox --scope catalog
for /f "tokens=4 delims= " %%a in ('%ACMD%') do set URL=%%a
set product-url=product_url: %URL%
echo %product-url%>subscriber.txt
echo plan: default>>subscriber.txt
type subscriber.txt
echo        :

echo subscribe new app to product
apic subscriptions:create --server %server% --org %porg_name% --consumer-org eights --catalog sandbox --app blackball subscriber.txt
echo        :


echo work done
apic logout --server %server% 
