#!/bin/bash

source ../services

keystone_db() {
  read -n1 -r -p "Create keystone database on '$(hostname)'. press ENTER to continue!" ENTER

  mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';"

  keystone_pkg
}

keystone_pkg() {
  read -n1 -r -p "Install and configure keystone on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/keystone ]]; then
    echo "[OSTACK] Keystone found.."
    echo "[OSTACK] Creating last configuration backup.."
    sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
  else
    echo "[OSTACK] Keystone not found.."
    echo "[OSTACK] Installing keystone.."
    sudo apt install keystone apache2 libapache2-mod-wsgi -y

    echo "[OSTACK] Creating configuration backup.."
    sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori
  fi

  echo "[OSTACK] Configuring keystone.."
  sudo cp ../config/keystone.conf /etc/keystone/keystone.conf

  echo "[OSTACK] Modifiying keystone permission.."
  sudo chown root:root /etc/keystone/keystone.conf
  sudo chmod 644 /etc/keystone/keystone.conf

  read -n1 -r -p "Populate keystone database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "keystone-manage db_sync" keystone

  read -n1 -r -p "Initialize fernet on '$(hostname)'. press ENTER to continue!" ENTER
  sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
  sudo keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

  read -n1 -r -p "Bootstrap keystone on '$(hostname)'. press ENTER to continue!" ENTER
  keystone-manage bootstrap --bootstrap-password ${KEYSTONE_ADMINPASS} --bootstrap-admin-url http://controller:5000/v3/ --bootstrap-internal-url http://controller:5000/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne

  apache
}

apache() {
  read -n1 -r -p "Install and configure apache2 on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -f /etc/apache2/apache2.conf ]]; then
    echo "[OSTACK] Apache2 found.."
    echo "[OSTACK] Creating last configuration backup.."
    sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
  else
    echo "[OSTACK] Apache2 not found.."
    echo "[OSTACK] Installing apache2.."
    sudo apt install apache2

    echo "[OSTACK] Creating original configuration backup.."
    sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.ori
  fi

  echo "[OSTACK] Configuring apache2.."
  sudo cp ../config/apache2.conf /etc/apache2/apache2.conf

  echo "[OSTACK] Modifiying apache2 permission.."
  sudo chown root:root /etc/apache2/apache2.conf
  sudo chmod 644 /etc/apache2/apache2.conf

  echo "[OSTACK] Restarting apache2.."
  sudo service apache2 restart

  echo "[OSTACK] Apache2 status"
  sudo service apache2 status

  echo "[OSTACK] Done."

  openrc
}

openrc() {
  read -n1 -r -p "Create openrc script on '$(hostname)'. press ENTER to continue!" ENTER

  mkdir ~/ostack-openrc

  echo "[OSTACK] Configuring init-openrc.."
  sudo cp ../config/init-openrc ~/ostack-openrc

  echo "[OSTACK] Configuring admin-openrc.."
  sudo cp ../config/admin-openrc ~/ostack-openrc

  echo "[OSTACK] Configuring demo-openrc.."
  sudo cp ../config/admin-openrc ~/ostack-openrc

  done_mesg
}

done_mesg() {
    echo "[OSTACK] Done."

    echo "==================================================================================="
    echo "Post installation note"
    echo "==================================================================================="
    echo "Configure administrative account in your linux enviroment.Before continue to next "
    echo "step on '4_conf_keystone.sh'.Use 'init-openrc' to load all enviroment varaible:"
    echo " "
    echo "$ . ~/ostack-openrc/init-openrc"
    echo " "
    echo "OR"
    echo " "
    echo "$ source ~/ostack-openrc/init-openrc"
    echo " "
    echo "==================================================================================="
    echo " "
    echo " "
}

echo "======================================================="
echo "Configure openstack KEYSTONE on '$(hostname)'.."
echo "======================================================="
keystone_db
