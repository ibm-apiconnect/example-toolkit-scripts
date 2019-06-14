server=$1
user=shells
password=Passw0rd
user_file=user-shells.txt
porg_name=shellorg
api_file=findbrancha.yaml
prod_file=brancha_prod.yaml

apic login --server ${server} --username ${user} --password ${password} --realm provider/default-idp-2

sleep 1

echo Current draft apis:
apic draft-apis:list-all --server ${server} --org ${porg_name}
echo Current draft products:
apic draft-products:list-all --server ${server} --org ${porg_name}
echo        :

echo create new draft prod
apic draft-products:create --server ${server} --org ${porg_name} brancha_prod.yaml
echo        :

echo publish same draft prod
res=$(apic products:publish --server ${server} --org ${porg_name} --catalog sandbox brancha_prod.yaml)
gURL=$(echo ${res} | cut -d' ' -f 4)
product_url="product_url: ${gURL}"
echo        :

# build replace product file
echo ${product_url}>prodmap.txt
echo "plans:">>prodmap.txt
echo "- source: default">>prodmap.txt
echo "  target: default">>prodmap.txt

echo Published product list
apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog
echo        :

echo create new api and prod yaml locally and stage

sed 's/version: 1.0.0/version: 2.0.0/g' findbrancha.yaml > findbrancha2.yaml
sed 's/version: 1.0.0/version: 2.0.0/g' brancha_prod.yaml > brancha_prod2.yaml
sed 's/findbrancha.yaml/findbrancha2.yaml/g' brancha_prod2.yaml

apic products:publish --server ${server} --org ${porg_name} --catalog sandbox --stage brancha_prod2.yaml
sleep 1
echo        :

echo list all products in catalog - note staged
apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog
echo        :

echo replace published with staged product
apic products:replace --server ${server} --org ${porg_name} --scope catalog --catalog sandbox findbrancha:2.0.0 prodmap.txt
echo        :

echo list all products in catalog - note state
apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog
echo        :

echo delete retired product
apic products:delete --server ${server} --org ${porg_name} --scope catalog --catalog sandbox findbrancha:1.0.0
echo        :

echo list products
apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog
echo        :

echo work done
apic logout --server ${server}