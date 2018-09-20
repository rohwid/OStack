#!/bin/bash

echo "==================================================================================="
echo "Configure openstack KEYSTONE on '$(hostname)'.."
echo "==================================================================================="
echo " "
echo "WARNING! Please execute it with user which load "
echo "'~/ostack-openrc/admin-openrc' as enviroment variable"
echo " "

read -n1 -r -p "Create new domain on keystone as example domain. press ENTER to continue!" ENTER
openstack domain create --description "An Example Domain" example

read -n1 -r -p "Create the service project as service project. press ENTER to continue!" ENTER
openstack project create --domain default --description "Service Project" service

read -n1 -r -p "Create myproject project as demo project. press ENTER to continue!" ENTER
openstack project create --domain default --description "Demo Project" myproject

read -n1 -r -p "Create myuser. press ENTER to continue!" ENTER
openstack user create --domain default --password-prompt myuser

read -n1 -r -p "Create myrole. press ENTER to continue!" ENTER
openstack role create myrole

read -n1 -r -p "Add role to myuser and myproject. press ENTER to continue!" ENTER
openstack role add --project myproject --user myuser myrole

read -n1 -r -p "Unset OS_AUTH_URL and OS_PASSWORD environment variable. press ENTER to continue!" ENTER
unset OS_AUTH_URL OS_PASSWORD

read -n1 -r -p "Request an authentication token as admin. press ENTER to continue!" ENTER
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin --os-username admin token issue

read -n1 -r -p "Request an authentication token as myuser. press ENTER to continue!" ENTER
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name myproject --os-username myuser token issue

echo "[OSTACK] Done."

echo "==================================================================================="
echo "POST INSTALLATION NOTE"
echo "==================================================================================="
echo "Load the 'admin-openrc' file to populate environment variables."
echo "It will also load the location of keystone and admin project and user credentials:"
echo " "
echo "$ . ~/ostack-openrc/admin-openrc"
echo " "
echo "OR"
echo " "
echo "$ source ~/ostack-openrc/admin-openrc"
echo " "
echo "Then request the authentication token:"
echo " "
echo "$ openstack token issue"
echo " "
echo "==================================================================================="
echo " "
echo " "
