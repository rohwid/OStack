#!/bin/bash

source ../services

chrony() {
  read -n1 -r -p "Install and configure NTP with chrony on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/chrony ]]; then
    echo "[OStack] Chrony found.."

    if [[ -f /etc/chrony/chrony.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

      echo "[OSTACK] Configuring NTP server with chrony.."
      sudo cp ../config/chrony.conf /etc/chrony/
    else
      echo "[OSTACK] Creating original configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori

      echo "[OSTACK] Configuring NTP with chrony.."
      sudo cp ../config/chrony.conf /etc/chrony/
    fi

    echo "[OSTACK] Restarting chrony.."
    sudo service chrony stop
    sudo chronyd -q "server controller iburst"
    sudo service chrony start

    echo "[OSTACK] Done."
    ostack_pkg
  else
    echo "[OSTACK] Chrony not found.."
    echo "[OSTACK] Installing chrony.."
    sudo apt install chrony -y

    if [[ -f /etc/chrony/chrony.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

      echo "[OSTACK] Configuring NTP server with chrony.."
      sudo cp ../config/chrony.conf /etc/chrony/
    else
      echo "[OSTACK] Creating original configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori

      echo "[OSTACK] Configuring NTP with chrony.."
      sudo cp ../config/chrony.conf /etc/chrony/
    fi

    echo "[OSTACK] Restarting chrony.."
    sudo service chrony stop
    sudo chronyd -q "server controller iburst"
    sudo service chrony start

    echo "[OSTACK] Done."
    ostack_pkg
  fi
}

ostack_pkg() {
  if [[ -f /usr/bin/openstack ]]; then
    exit
  else
    read -n1 -r -p "Install openstack package on '$(hostname)'. press ENTER to continue!" ENTER

    echo "[OSTACK] Installing Openstack packages.."
    sudo apt install python-openstackclient -y
  fi
}

echo "======================================================="
echo "[OSTACK] CONFIGURING ENVIRONMENT ON '$(hostname)'.."
echo "======================================================="
chrony
