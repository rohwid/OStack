#!/bin/bash

source ../services

db() {
  read -p "Have you register keystone to database? [Y/N]: " OPT

  case "${OPT}" in
      Y)  pkg
          ;;
      y)  pkg
          ;;
      N)  read -n1 -r -p "Create keystone database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';"

          pkg
          ;;
      n)  read -n1 -r -p "Create keystone database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';"

          pkg
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

pkg() {
  read -n1 -r -p "Install and configure keystone on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/keystone ]]; then
    echo "[OSTACK] Keystone found.."
    echo "[OSTACK] Creating last configuration backup.."

    if [[ -f /etc/keystone/keystone.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      sudo cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak
    else
      echo "[OSTACK] Creating original configuration backup.."
      sudo cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.ori
    fi
  else
    echo "[OSTACK] Keystone not found.."
    echo "[OSTACK] Installing keystone.."
    sudo apt install keystone apache2 libapache2-mod-wsgi -y

    echo "[OSTACK] Creating original configuration backup.."
    sudo cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.ori
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
}

apache2() {
  read -n1 -r -p "Install and configure apache2 on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/apache2 ]]; then
    echo "[OSTACK] Apache2 found.."
    echo "[OSTACK] Creating last configuration backup.."

    if [[ -f /etc/apache2/apache2.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
    else
      echo "[OSTACK] Creating original configuration backup.."
      sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.ori
    fi
  else
    echo "[OSTACK] Apache2 not found.."
    echo "[OSTACK] Installing apache2.."
    sudo apt install apache2 libapache2-mod-wsgi -y

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
}

openrc() {
  read -n1 -r -p "Create openrc script on '$(hostname)'. press ENTER to continue!" ENTER

  mkdir ~/ostack-openrc

  echo "[OSTACK] Configuring init-openrc.."
  if [[ ! -f ~/ostack-openrc/init-openrc ]];then
    sudo cp ../config/init-openrc ~/ostack-openrc
  fi

  echo "[OSTACK] Configuring admin-openrc.."
  if [[ ! -f ~/ostack-openrc/admin-openrc ]];then
    sudo cp ../config/admin-openrc ~/ostack-openrc
  fi

  echo "[OSTACK] Configuring demo-openrc.."
  if [[ ! -f ~/ostack-openrc/demo-openrc ]];then
    sudo cp ../config/demo-openrc ~/ostack-openrc
  fi
}

done_mesg() {
    echo " "
    echo "====================================================================================="
    echo "Post installation note"
    echo "====================================================================================="
    echo "Configure administrative account in your linux enviroment.Before continue to next "
    echo "step on '4_conf_keystone.sh'.Use 'init-openrc' to load all enviroment varaible:"
    echo " "
    echo " $ . ~/ostack-openrc/init-openrc"
    echo " "
    echo " OR"
    echo " "
    echo " $ source ~/ostack-openrc/init-openrc"
    echo " "
    echo "====================================================================================="
    echo " "
    echo " "
}

echo "====================================================================================="
echo "Configure openstack KEYSTONE on '$(hostname)'.."
echo "====================================================================================="
db
apache2
openrc

echo "[OSTACK] Done."
done_mesg
