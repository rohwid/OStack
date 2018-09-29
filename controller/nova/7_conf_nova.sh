#!/bin/bash

source ../services

echo " "
echo "==================================================================================="
echo "Add compute node to NOVA cell database on '$(hostname)'"
echo "==================================================================================="
echo " "
echo "WARNING! Make you have configure NOVA on compute node and execute it with the user"
echo "which load '~/ostack-openrc/admin-openrc' to his enviroment variable"
echo " "
echo " $ . ~/ostack-openrc/admin-openrc"
echo " "
echo " OR"
echo " "
echo " $ source ~/ostack-openrc/admin-openrc"
echo " "
echo "==================================================================================="
echo " "

read -n1 -r -p "Create new domain on keystone as example domain. press ENTER to continue!" ENTER
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

read -n1 -r -p "Create new domain on keystone as example domain. press ENTER to continue!" ENTER
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

# TODO
# ADD SCHEDULER TO ADD MORE THAN ONE NODES
# READ SERVER CONFIG FILE

echo "[OSTACK] Nova done."

echo " "
echo "==================================================================================="
echo "POST INSTALLATION NOTE"
echo "==================================================================================="
echo "Load the 'admin-openrc' file to populate environment variables."
echo "It will also load the location of keystone and admin project and user credentials:"
echo " "
echo " $ . ~/ostack-openrc/admin-openrc"
echo " "
echo " OR"
echo " "
echo " $ source ~/ostack-openrc/admin-openrc"
echo " "
echo "Make sure you have configure the compute node first. Then execute it to "
echo "list service components to verify successful launch and register every process:"
echo " "
echo " $ openstack compute service list"
echo " "
echo "List API endpoints in keystone to verify connection with keystone:"
echo " "
echo " $ openstack catalog list"
echo " "
echo "List images in keystone to verify connectivity with glance:"
echo " "
echo " $ openstack image list"
echo " "
echo "Login as root and Check the cells and placement API are working successfully:"
echo " "
echo " # nova-status upgrade check"
echo " "
echo "==================================================================================="
echo " "
echo " "
