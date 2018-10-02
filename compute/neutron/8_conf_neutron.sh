#!/bin/bash

source ../services

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

    if [[ -f /etc/neutron/plugins/ml2/linuxbridge_agent.ini.ori ]]; then
      echo "[OSTACK] Creating linuxbridge_agent last configuration backup.."
      sudo cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.bak
    else
      echo "[OSTACK] Creating linuxbridge_agent original configuration backup.."
      sudo cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.ori
    fi
  else
    echo "[OSTACK] Neutron not found.."
    echo "[OSTACK] Installing neutron.."
    sudo apt install neutron-linuxbridge-agent -y

    echo "[OSTACK] Creating neutron configuration backup.."
    sudo cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.ori

    echo "[OSTACK] Creating linuxbridge_agent original configuration backup.."
    sudo cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.ori
  fi

  echo "[OSTACK] Configuring neutron.."
  sudo cp ../config/neutron.conf /etc/neutron/neutron.conf

  echo "[OSTACK] Modifiying neutron permission.."
  sudo chown root:neutron /etc/neutron/neutron.conf
  sudo chmod 640 /etc/neutron/neutron.conf

  echo "[OSTACK] Creating linuxbridge_agent original configuration backup.."
  sudo cp ../config/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini

  echo "[OSTACK] Modifiying linuxbridge_agent permission.."
  sudo chown root:neutron /etc/neutron/plugins/ml2/linuxbridge_agent.ini
  sudo chmod 644 /etc/neutron/plugins/ml2/linuxbridge_agent.ini

  echo "[OSTACK] Restarting nova-compute.."
  sudo service nova-compute restart

  echo "[OSTACK] Restarting neutron-linuxbridge-agent.."
  sudo service neutron-linuxbridge-agent restart

  echo "[OSTACK] Neutron done."

  echo " "
  echo "==================================================================================="
  echo "POST INSTALLATION NOTE"
  echo "==================================================================================="
  echo "Load the 'admin-openrc' file on CONTROLLER to populate environment variables."
  echo "It will also load the location of keystone and admin project and user credentials:"
  echo " "
  echo " $ . ~/ostack-openrc/admin-openrc"
  echo " "
  echo " OR"
  echo " "
  echo " $ source ~/ostack-openrc/admin-openrc"
  echo " "
  echo "Make sure you have configure every compute nodes first. Then execute it to "
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
read -n1 -r -p "Ensure your OS kernel supports network bridge filterspress ENTER to continue!" ENTER

echo "[OSTACK] Here is the value of net.bridge.bridge-nf-call-iptables: "
sysctl net.bridge.bridge-nf-call-iptables

echo "[OSTACK] Here is the value of sysctl net.bridge.bridge-nf-call-ip6tables: "
sysctl net.bridge.bridge-nf-call-ip6tables

read -n1 -r -p "Make sure all values are set to 1. Press ENTER to continue or CTRL+C to cancel!" ENTER

pkg

echo "[OSTACK] Done."
