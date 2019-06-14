server=$1
user=admin
password=$2
user_file=user-shells.txt
porg_name=shellorg
api_file=findbrancha.yaml
prod_file=brancha_prod.yaml

echo name: ${porg_name}>${porg_name}.txt
echo title: ${porg_name}>>${porg_name}.txt


echo log in as CMC admin
apic login --server ${server} --username ${user} --password ${password} --realm admin/default-idp-1
echo               :

echo create new provider org admin user and build org file
sleep 2
ret=$(apic users:create --server ${server} --org admin --user-registry api-manager-lur ${user_file})
URL=$(echo ${ret} | cut -d' ' -f 4)
owner_url="owner_url: ${URL}"
echo ${owner_url}>>${porg_name}.txt
cat ${porg_name}.txt
echo        :

echo create new provider org
apic orgs:create --server ${server} ${porg_name}.txt
sleep 2

echo log out as cmc admin
apic logout --server ${server}

sleep 1

echo               :

newuser=$(grep "username" ${user_file} | cut -d' ' -f 2)
newuserpassword=$(grep "password" ${user_file} | cut -d' ' -f 2)

echo logging in Provider ${porg_name} with ${newuser} ${newuserpassword}
apic login --server ${server} --username ${newuser} --password ${newuserpassword} --realm provider/default-idp-2
echo               :
sleep 1

echo list available gateways
n=0
ans=$(apic gateway-services:list --server ${server} --scope org --org ${porg_name})
while IFS= read -r line
do
   n=$(($n + 1))
gURL=$(echo ${line} | cut -d' ' -f 2)
gateway_url="gateway_service_url: ${gURL}"
echo ${gateway_url}
echo ${gateway_url}>gwsvc${n}.txt
done <<< ${ans}


echo there are ${n} gateways available
echo               :
echo configure gateways for sandbox catalog

for (( c=1; c<=${n}; c++ ))
do  
   apic configured-gateway-services:create --server ${server} --org ${porg_name} --scope catalog --catalog sandbox gwsvc${c}.txt
done

echo work complete log out
apic logout --server ${server}




