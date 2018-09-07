#!/bin/bash

## TODO
## Auto generate config --> generate-config.sh
## save temp IP address --> servers.sh
## include rabbitmq user and pass--> services.sh
## host --> hosts --> auto assign IP and host
## chrony --> chrony.conf --> auto assign chrony server
## mariadb --> 99-openstack.cnf --> auto assign IP
## memcached --> memecached.conf --> auto assign IP
## etcd --> etcd --> auto assign IP


source ../services.sh

chrony() {
  echo "======================================================="
  echo "[OSTACK] Configure NTP in controller"
  echo "======================================================="

  if [[ -d /etc/chrony ]]; then
    echo "[OStack] Chrony found.."

    if [[ -f /etc/chrony/chrony.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

      echo "[OSTACK] Configuring NTP server with chrony.."
      cp ../config/chrony.conf /etc/chrony/
    else
      echo "[OSTACK] Creating original configuration backup.."
      cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori

      echo "[OSTACK] Configuring NTP with chrony.."
      cp ../config/chrony.conf /etc/chrony/
    fi

    echo "[OSTACK] Restarting chrony.."
    service chrony restart

    echo "[OSTACK] Done."
    ostack_pkg
  else
    echo "[OSTACK] Chrony not found.."
    echo "[OSTACK] Installing chrony.."
    apt install chrony -y

    if [[ -f /etc/chrony/chrony.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

      echo "[OSTACK] Configuring NTP server with chrony.."
      cp ../config/chrony.conf /etc/chrony/
    else
      echo "[OSTACK] Creating original configuration backup.."
      cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori

      echo "[OSTACK] Configuring NTP with chrony.."
      cp ../config/chrony.conf /etc/chrony/
    fi

    echo "[OSTACK] Restarting chrony.."
    service chrony restart

    echo "[OSTACK] Done."
    ostack_pkg
  fi
}

ostack_pkg() {
  if [[ -f /usr/bin/openstack ]]; then
    exit
  else
    echo "======================================================="
    echo "[OSTACK] Install Openstack Packages"
    echo "======================================================="
    
    echo "[OSTACK] Installing Openstack packages.."
    apt install python-openstackclient -y
  fi
}

echo "[OSTACK] CONFIGURING ENVIRONMENT ON '$(hostname)'.."
chrony
