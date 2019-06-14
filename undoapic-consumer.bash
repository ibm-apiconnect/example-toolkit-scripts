server=$1
user=shells
password=Passw0rd
porg_name=shellorg


echo log in as provider org owner
apic login --username ${user} --password ${password} --realm provider/default-idp-2
sleep 1
echo        :

echo delete apps in consumer org
apic apps:delete --server ${server} --org ${porg_name} --catalog sandbox --consumer-org tenths blackball
echo        :

echo List apps in consumer org
apic apps:list --server ${server} --org ${porg_name} --catalog sandbox --consumer-org tenths 
echo        :

echo delete consumer org
apic consumer-orgs:delete --server ${server} --org ${porg_name} --catalog sandbox tenths
sleep 2
echo        :

echo list consumer org
apic consumer-orgs:list --server ${server} --org ${porg_name} --catalog sandbox 
echo        :

echo delete consumer org user
apic users:delete --server ${server} --org ${porg_name} --user-registry sandbox-catalog tenth
sleep 2
echo        :

echo list catalog users
apic users:list --server ${server} --org ${porg_name} --user-registry sandbox-catalog
echo        :

echo work done
apic logout --server ${server}
