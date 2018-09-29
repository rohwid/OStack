#!/bin/bash

source ../services

db() {
  read -p "Have you register NEUTRON to database? [Y/N]: " OPT

  case "${OPT}" in
      Y)  register
          ;;
      y)  register
          ;;
      N)  read -n1 -r -p "Create NEUTRON database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE neutron; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';"

          register
          ;;
      n)  read -n1 -r -p "Create NEUTRON database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE neutron; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DBPASS}'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DBPASS}';"

          register
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

register() {
  read -p "Have you register NEUTRON to KEYSTONE? [Y/N]: " OPT

  case "${OPT}" in
      Y)  pkg
          ;;
      y)  pkg
          ;;
      N)  read -n1 -r -p "Create neutron user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt neutron

          read -n1 -r -p "Add admin role to neutron user. press ENTER to continue!" ENTER
          openstack role add --project service --user neutron admin

          read -n1 -r -p "Create the neutron service entity. press ENTER to continue!" ENTER
          openstack service create --name neutron --description "OpenStack Networking" network

          read -n1 -r -p "Create public Network service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne network public http://controller:9696

          read -n1 -r -p "Create internal Network service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne network internal http://controller:9696

          read -n1 -r -p "Create admin Network service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne network admin http://controller:9696

          pkg
          ;;
      n)  read -n1 -r -p "Create neutron user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt neutron

          read -n1 -r -p "Add admin role to neutron user. press ENTER to continue!" ENTER
          openstack role add --project service --user neutron admin

          read -n1 -r -p "Create the neutron service entity. press ENTER to continue!" ENTER
          openstack service create --name neutron --description "OpenStack Networking" network

          read -n1 -r -p "Create public Network service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne network public http://controller:9696

          read -n1 -r -p "Create internal Network service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne network internal http://controller:9696

          read -n1 -r -p "Create admin Network service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne network admin http://controller:9696

          pkg
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

pkg() {
  read -n1 -r -p "Install NEUTRON package on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/neutron ]]; then
    echo "[OSTACK] Neutron found.."
    echo "[OSTACK] Creating last configuration backup.."

    if [[ -f /etc/neutron/neutron.conf.ori ]]; then
      echo "[OSTACK] Creating neutron last configuration backup.."
      sudo cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak
    else
      echo "[OSTACK] Creating neutron original configuration backup.."
      sudo cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.ori
    fi

    if [[ -f /etc/neutron/plugins/ml2/ml2_conf.ini.ori ]]; then
      echo "[OSTACK] Creating ml2_conf last configuration backup.."
      sudo cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.bak
    else
      echo "[OSTACK] Creating ml2_conf original configuration backup.."
      sudo cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.ori
    fi

    if [[ -f /etc/neutron/plugins/ml2/linuxbridge_agent.ini.ori ]]; then
      echo "[OSTACK] Creating linuxbridge_agent last configuration backup.."
      sudo cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak
    else
      echo "[OSTACK] Creating linuxbridge_agent original configuration backup.."
      sudo cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.ori
    fi

    if [[ -f /etc/neutron/l3_agent.ini.ori ]]; then
      echo "[OSTACK] Creating l3_agent last configuration backup.."
      sudo cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.bak
    else
      echo "[OSTACK] Creating l3_agent original configuration backup.."
      sudo cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.ori
    fi

    if [[ -f /etc/neutron/dhcp_agent.ini ]]; then
      echo "[OSTACK] Creating dhcp_agent last configuration backup.."
      sudo cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.bak
    else
      echo "[OSTACK] Creating dhcp_agent original configuration backup.."
      sudo cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.ori
    fi

    if [[ -f /etc/neutron/metadata_agent.ini ]]; then
      echo "[OSTACK] Creating dhcp_agent last configuration backup.."
      sudo cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.bak
    else
      echo "[OSTACK] Creating dhcp_agent original configuration backup.."
      sudo cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.ori
    fi
  else
    echo "[OSTACK] Neutron not found.."
    echo "[OSTACK] Installing neutron.."
    sudo apt install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent -y

    echo "[OSTACK] Creating neutron configuration backup.."
    sudo cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.ori

    echo "[OSTACK] Creating ml2_conf original configuration backup.."
    sudo cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.ori

    echo "[OSTACK] Creating linuxbridge_agent original configuration backup.."
    sudo cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.ori

    echo "[OSTACK] Creating l3_agent original configuration backup.."
    sudo cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.ori

    echo "[OSTACK] Creating dhcp_agent original configuration backup.."
    sudo cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.ori

    echo "[OSTACK] Creating metadata_agent original configuration backup.."
    sudo cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.ori
  fi

  echo "[OSTACK] Configuring neutron.."
  sudo cp ../config/neutron.conf /etc/neutron/neutron.conf

  echo "[OSTACK] Modifiying neutron permission.."
  sudo chown root:neutron /etc/neutron/neutron.conf
  sudo chmod 640 /etc/neutron/neutron.conf

  echo "[OSTACK] Configuring ml2_conf.."
  sudo cp ../config/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

  echo "[OSTACK] Modifiying ml2_conf permission.."
  sudo chown root:neutron /etc/neutron/plugins/ml2/ml2_conf.ini
  sudo chmod 644 /etc/neutron/plugins/ml2/ml2_conf.ini

  echo "[OSTACK] Creating linuxbridge_agent original configuration backup.."
  sudo cp ../config/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini

  echo "[OSTACK] Modifiying linuxbridge_agent permission.."
  sudo chown root:neutron /etc/neutron/plugins/ml2/linuxbridge_agent.ini
  sudo chmod 644 /etc/neutron/plugins/ml2/linuxbridge_agent.ini

  echo "[OSTACK] Configuring l3_agent.."
  sudo cp ../config/l3_agent.ini /etc/neutron/l3_agent.ini

  echo "[OSTACK] Modifiying l3_agent permission.."
  sudo chown root:neutron /etc/neutron/l3_agent.ini
  sudo chmod 644 /etc/neutron/l3_agent.ini

  echo "[OSTACK] Creating dhcp_agent.."
  sudo cp ../config/l3_agent.ini /etc/neutron/dhcp_agent.ini

  echo "[OSTACK] Modifiying dhcp_agent permission.."
  sudo chown root:neutron /etc/neutron/dhcp_agent.ini
  sudo chmod 644 /etc/neutron/dhcp_agent.ini

  read -n1 -r -p "Populate neutron database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

  echo "[OSTACK] Restarting nova-api.."
  sudo service nova-api restart

  echo "[OSTACK] Restarting neutron-server.."
  sudo service neutron-server restart

  echo "[OSTACK] Restarting neutron-linuxbridge-agent.."
  sudo service neutron-linuxbridge-agent restart

  echo "[OSTACK] Restarting neutron-dhcp-agent.."
  sudo service neutron-dhcp-agent restart

  echo "[OSTACK] Restarting neutron-metadata-agent.."
  sudo service neutron-metadata-agent restart

  echo "[OSTACK] Restarting neutron-l3-agent.."
  sudo service neutron-l3-agent restart

  echo "[OSTACK] Neutron done."

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
  echo "Make sure you have configure the the compute node first. Then execute it to "
  echo "list agents to verify successful launch of the neutron agents:"
  echo " "
  echo " $ openstack network agent list"
  echo " "
  echo "==================================================================================="
  echo " "
  echo " "
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

echo "[OSTACK] Done."
