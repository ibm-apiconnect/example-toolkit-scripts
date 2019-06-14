server=$1
user=shells
password=Passw0rd
porg_name=shellorg
api_file=findbrancha.yaml
prod_file=brancha_prod.yaml

# build consumer user file
echo "username: tenth">user-tenth.txt
echo "email: tenth@example.com">>user-tenth.txt
echo "first_name: Tenth">>user-tenth.txt
echo "last_name: Man">>user-tenth.txt
echo "password: Passw0rd">>user-tenth.txt

echo Here is the consumer org owner
echo        :
cat user-tenth.txt
echo        :
echo "name: tenths">tenths-org.txt
echo "title: Tenth Man">>tenths-org.txt


apic login --username ${user} --password ${password} --realm provider/default-idp-2

sleep 1

echo        :
echo create new catalog user

res=$(apic users:create --server ${server} --org ${porg_name} --user-registry sandbox-catalog user-tenth.txt)
sid=$(echo ${res} | cut -d' ' -f 4)
owner_url="owner_url: ${sid}"
echo ${owner_url}>>tenths-org.txt
cat tenths-org.txt
echo        :

echo create new consumer org

apic consumer-orgs:create --server ${server} --org ${porg_name} --catalog sandbox tenths-org.txt
sleep 2
echo        :

echo "title: blackball">black-app.txt
echo Create new app in new consumer org
apic apps:create --consumer-org tenths --catalog sandbox --server ${server} --org ${porg_name} black-app.txt
echo        :

echo Product for subscription
res=$(apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog) 
gURL=$(echo ${res} | cut -d' ' -f 4)
product_url="product_url: ${gURL}"
echo ${product_url}>subscriber.txt
echo "plan: default">>subscriber.txt
cat subscriber.txt

echo        :
echo Subscribe new app to product
apic subscriptions:create --server ${server} --org ${porg_name} --consumer-org tenths --catalog sandbox --app blackball  subscriber.txt
echo        :

echo work done
apic logout --server ${server}
