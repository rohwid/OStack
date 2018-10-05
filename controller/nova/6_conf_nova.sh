#!/bin/bash

source ../services

db() {
  read -p "Have you register NOVA to database? [Y/N]: " OPT

  case "${OPT}" in
      Y)  register
          ;;
      y)  register
          ;;
      N)  read -n1 -r -p "Create NOVA database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE nova_api; GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}'; GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';"

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';"

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE nova_cell0; GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}'; GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';"

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE placement; GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '${PLACEMENT_DBPASS}'; GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '${PLACEMENT_DBPASS}';"

          register
          ;;
      n)  read -n1 -r -p "Create NOVA database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE nova_api; GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}'; GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';"

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';"

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE nova_cell0; GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DBPASS}'; GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DBPASS}';"

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE placement; GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '${PLACEMENT_DBPASS}'; GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '${PLACEMENT_DBPASS}';"

          register
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

register() {
  read -p "Have you register NOVA to KEYSTONE? [Y/N]: " OPT

  case "${OPT}" in
      Y)  pkg
          ;;
      y)  pkg
          ;;
      N)  read -n1 -r -p "Create nova user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt nova

          read -n1 -r -p "Add admin role to nova user and service project. press ENTER to continue!" ENTER
          openstack role add --project service --user nova admin

          read -n1 -r -p "Create the nova service entity. press ENTER to continue!" ENTER
          openstack service create --name nova --description "OpenStack Compute" compute

          read -n1 -r -p "Create public Compute service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1

          read -n1 -r -p "Create internal Compute service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1

          read -n1 -r -p "Create admin Compute service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1

          read -n1 -r -p "Create Placement service user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt placement

          read -n1 -r -p "Add Placement user to service project as admin. press ENTER to continue!" ENTER
          openstack role add --project service --user placement admin

          read -n1 -r -p "Create Placement API entry in service catalog. press ENTER to continue!" ENTER
          openstack service create --name placement --description "Placement API" placement

          read -n1 -r -p "Create public Placement API service endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne placement public http://controller:8778

          read -n1 -r -p "Create internal Placement API service endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne placement internal http://controller:8778

          read -n1 -r -p "Create admin API service endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne placement admin http://controller:8778

          pkg
          ;;
      n)  read -n1 -r -p "Create nova user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt nova

          read -n1 -r -p "Add admin role to nova user and service project. press ENTER to continue!" ENTER
          openstack role add --project service --user nova admin

          read -n1 -r -p "Create the nova service entity. press ENTER to continue!" ENTER
          openstack service create --name nova --description "OpenStack Compute" compute

          read -n1 -r -p "Create public Compute service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1

          read -n1 -r -p "Create internal Compute service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1

          read -n1 -r -p "Create admin Compute service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1

          read -n1 -r -p "Create Placement service user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt placement

          read -n1 -r -p "Add Placement user to service project as admin. press ENTER to continue!" ENTER
          openstack role add --project service --user placement admin

          read -n1 -r -p "Create Placement API entry in service catalog. press ENTER to continue!" ENTER
          openstack service create --name placement --description "Placement API" placement

          read -n1 -r -p "Create public Placement API service endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne placement public http://controller:8778

          read -n1 -r -p "Create internal Placement API service endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne placement internal http://controller:8778

          read -n1 -r -p "Create admin API service endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne placement admin http://controller:8778

          pkg
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

pkg() {
  read -n1 -r -p "Install NOVA package on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/nova ]]; then
    echo "[OSTACK] Nova found.."
    echo "[OSTACK] Creating last configuration backup.."

    if [[ -f /etc/nova/nova.conf.ori ]]; then
      echo "[OSTACK] Creating nova last configuration backup.."
      sudo cp /etc/nova/nova.conf /etc/nova/nova.conf.bak
    else
      echo "[OSTACK] Creating nova original configuration backup.."
      sudo cp /etc/nova/nova.conf /etc/nova/nova.conf.ori
    fi
  else
    echo "[OSTACK] Nova not found.."
    echo "[OSTACK] Installing nova.."
    sudo apt install nova-api nova-conductor nova-novncproxy nova-scheduler nova-placement-api -y

    echo "[OSTACK] Creating nova configuration backup.."
    sudo cp /etc/nova/nova.conf /etc/nova/nova.conf.ori
  fi

  echo "[OSTACK] Configuring nova.."
  sudo cp ../config/nova.conf /etc/nova/nova.conf

  echo "[OSTACK] Modifiying nova permission.."
  sudo chown nova:nova /etc/nova/nova.conf
  sudo chmod 640 /etc/nova/nova.conf

  read -n1 -r -p "Populate nova-api and placement database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "nova-manage api_db sync" nova

  read -n1 -r -p "Register cell0 database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

  read -n1 -r -p "Create cell1 database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova

  read -n1 -r -p "Populate nova database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "nova-manage db sync" nova

  read -n1 -r -p "Verify nova cell0 and cell1 are registered correctly. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

  echo "[OSTACK] Restarting nova-api.."
  sudo service nova-api restart

  echo "[OSTACK] Restarting nova-scheduler.."
  sudo service nova-scheduler restart

  echo "[OSTACK] Restarting nova-conductor.."
  sudo service nova-conductor restart

  echo "[OSTACK] Restarting nova-novncproxy.."
  sudo service nova-novncproxy restart
}

restart_script() {
  read -n1 -r -p "Create nova restart script on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ ! -d ~/restart-script ]];then
    mkdir ~/restart-script
  fi

  echo "[OSTACK] Configuring restart-nova.."
  if [[ ! -f ~/restart-script/restart-nova.sh ]];then
    cp ../config/restart-nova.sh ~/restart-script/
  fi
}


echo " "
echo "==================================================================================="
echo "Configure openstack NOVA on '$(hostname)'.."
echo "==================================================================================="
echo " "
echo "WARNING! Please make sure you have execute '~/ostack-openrc/admin-openrc'"
echo "as enviroment variable before continue this process."
echo " "
echo " $ . ~/ostack-openrc/admin-openrc"
echo " "
echo " OR"
echo " "
echo " $ source ~/ostack-openrc/admin-openrc"
echo " "
echo "==================================================================================="

read -n1 -r -p "Press ENTER to continue or CTRL+C to cancel!" ENTER
db
restart_script

echo "[OSTACK] Done."
