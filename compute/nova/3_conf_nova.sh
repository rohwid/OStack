#!/bin/bash

source ../services

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

    if [[ -f /etc/nova/nova-compute.conf.ori ]]; then
      echo "[OSTACK] Creating nova last configuration backup.."
      sudo cp /etc/nova/nova-compute.conf /etc/nova/nova-compute.conf.bak
    else
      echo "[OSTACK] Creating nova original configuration backup.."
      sudo cp /etc/nova/nova-compute.conf /etc/nova/nova-compute.conf.ori
    fi
  else
    echo "[OSTACK] Nova not found.."

    read -n1 -r -p "Check hardware acceleration support on '$(hostname)'. press ENTER to continue!" ENTER
    egrep -c '(vmx|svm)' /proc/cpuinfo

    echo "[OSTACK] Installing nova.."
    sudo apt install nova-compute -y

    echo "[OSTACK] Creating configuration backup.."
    sudo cp /etc/nova/nova.conf /etc/nova/nova.conf.ori
  fi

  echo "[OSTACK] Configuring nova.."
  sudo cp ../config/nova.conf /etc/nova/nova.conf
  sudo cp ../config/nova-compute.conf /etc/nova/nova-compute.conf

  echo "[OSTACK] Modifiying nova permission.."
  sudo chown nova:nova /etc/nova/nova.conf
  sudo chmod 640 /etc/nova/nova.conf
  sudo chown nova:nova /etc/nova/nova-compute.conf
  sudo chmod 600 /etc/nova/nova-compute.conf

  echo "[OSTACK] Restarting nova-compute.."
  sudo service nova-compute restart

  echo "[OSTACK] Nova compute done."

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
}

echo " "
echo "==================================================================================="
echo "Configure openstack NOVA on '$(hostname)'.."
echo "==================================================================================="
echo " "
read -n1 -r -p "Press ENTER to continue or CTRL+C to cancel!" ENTER
pkg

echo "[OSTACK] Nova-compute done."
