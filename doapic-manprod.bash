server=$1
user=shells
password=Passw0rd
user_file=user-shells.txt
porg_name=shellorg
api_file=findbrancha.yaml
prod_file=brancha_prod.yaml

apic login --server ${server} --username ${user} --password ${password} --realm provider/default-idp-2
sleep 1
echo        :

echo Published product list
res=$(apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog)
gURL=$(echo ${res} | cut -d' ' -f 4)
product_url="product_url: ${gURL}"
echo ${product_url}>supersede.txt
echo        :

echo build supercede map
echo "plans:">>supersede.txt
echo "- source: default">>supersede.txt
echo "  target: default">>supersede.txt
cat supersede.txt
echo        :

echo check subscriptions to existing prod
apic subscriptions:list --server ${server} --app blackball --catalog sandbox --org ${porg_name} --consumer-org tenths
echo        :

echo stage a superceding product
res=$(apic products:publish --server ${server} --org ${porg_name} --catalog sandbox --stage brancha_prod.yaml ) 
gURL=$(echo ${res} | cut -d' ' -f 4)
product_url="product_url: ${gURL}"
echo ${product_url}>migrate.txt

echo supercede existing product
apic products:supersede --server ${server} --org ${porg_name} --catalog sandbox --scope catalog findbrancha:1.0.0 supersede.txt
echo        :

echo product states
apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog 
echo        :

echo subscription states
res=$(apic subscriptions:list --server ${server} --app blackball --catalog sandbox --org ${porg_name} --consumer-org tenths)
sid=$(echo ${res} | cut -d' ' -f 1)
echo "subscription id ${sid}"
echo        :

apic subscriptions:get --server ${server} --app blackball --catalog sandbox --org ${porg_name} --consumer-org tenths ${sid}

echo show subscription details examine product url
grep "product" ${sid}.yaml
echo        :

echo build migration target file
echo "plans:">>migrate.txt
echo "- source: default">>migrate.txt
echo "  target: default">>migrate.txt
cat migrate.txt
echo        :

echo set migration target
apic products:set-migration-target --server ${server} --org ${porg_name} --catalog sandbox --scope catalog findbrancha:2.0.0 migrate.txt
echo        :

echo migrate subscriptions
apic products:execute-migration-target --server ${server} --org ${porg_name} --catalog sandbox --scope catalog findbrancha:2.0.0
echo        :

echo subscription states
res=$(apic subscriptions:list --server ${server} --app blackball --catalog sandbox --org ${porg_name} --consumer-org tenths)
sid=$(echo ${res} | cut -d' ' -f 1)
echo "subscription id is now ${sid}"
echo        :

echo show subscription details examine product url
apic subscriptions:get --server ${server} --app blackball --catalog sandbox --org ${porg_name} --consumer-org tenths --output - ${sid}

echo work done
apic logout --server ${server}

