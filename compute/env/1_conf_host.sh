#!/bin/bash

source ../services

config_hosts() {
  read -n1 -r -p "Change hosts on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -f /etc/hosts.ori ]]; then
    echo "[OSTACK] Backup current configuration.."
    sudo cp /etc/hosts /etc/hosts.bak
  else
    echo "[OSTACK] Backup original configuration.."
    sudo cp /etc/hosts /etc/hosts.ori

    echo "[OSTACK] Configuring openstack controller hosts.."
    sudo cp ../config/hosts /etc/hosts
  fi

  echo "[OSTACK] Done."
  config_hostname
}

config_hostname() {
  read -n1 -r -p "Change hostname '$(hostname)' to 'controller'. press ENTER to continue!" ENTER

  if [[ -f /etc/hostname.ori ]]; then
    echo "[OSTACK] Configuring openstack controller hostname.."
    sudo echo "compute${NUM}" > /etc/hostname
  else
    echo "[OSTACK] Backup original configuration.."
    sudo cp /etc/hostname /etc/hostname.ori

    echo "[OSTACK] Configuring openstack controller hosts.."
    sudo echo "compute${NUM}" > /etc/hostname
  fi

  echo "[OSTACK] Done."
  do_reboot
}

do_reboot() {
  read -n1 -r -p "Reboot to apply all changes. Press ENTER to reboot!" ENTER

  if [[ $ENTER=\n ]]; then
    sudo reboot
  else
    echo "[OSTACK] This server need to reboot. Please reboot to apply all changes!"
    echo "[OSTACK] Finish."
  fi
}


echo " "
echo "==================================================================================="
echo "Configure openstack controller hosts and hostname"
echo "==================================================================================="
echo " "
echo "WARNING! Please make sure you have execute it as root or using sudo"
echo " "
echo "==================================================================================="
read -n1 -r -p "Press ENTER to continue or CTRL+C to cancel!" ENTER
echo " "
read -p "Enter compute number [1 - n]: " NUM
config_hosts
