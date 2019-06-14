server=$1
user=admin
password=$2
user_file=user-shells.txt
porg_name=shellorg


newuser=$(grep "username" ${user_file} | cut -d' ' -f 2)
newuserpassword=$(grep "password" ${user_file} | cut -d' ' -f 2)

echo logging in Provider ${porg_name} with ${newuser} ${newuserpassword}
apic login --server ${server} --username ${newuser} --password ${newuserpassword} --realm provider/default-idp-2
echo               :
sleep 1

echo remove all products
apic products:clear-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog --confirm sandbox
apic products:list-all --server ${server} --org ${porg_name} --catalog sandbox --scope catalog

echo log out as provider admin
apic logout--server ${server}

echo Log in as CMC admin
apic login --server ${server} --username ${user} --password ${password} --realm admin/default-idp-1
sleep 2
echo               :

echo        :
echo delete Provider org - long delay
apic orgs:delete --server ${server} ${porg_name}
sleep 3

echo        :
echo delete org admin user
apic users:delete --server ${server} --org admin --user-registry api-manager-lur ${newuser}

echo        :
echo list users
apic users:list --server ${server} --org admin --user-registry api-manager-lur

echo work complete log out
apic logout--server ${server}




