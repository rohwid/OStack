#!/bin/bash

source ../../services

add_db() {
  echo "======================================================="
  echo "[OSTACK] Create keystone database"
  echo "======================================================="

  echo "[OSTACK] CONFIGURING 'keystone' DATABASE ON '$(hostname)'.."

  mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';"

  echo "[OSTACK] Done."
}

conf_keystone() {
  echo "======================================================="
  echo "[OSTACK] Configure Keystone"
  echo "======================================================="

  # TO DO, check configuration on server!

  if [[ -d /etc/keystone ]]; then
    echo "[OSTACK] Configuring keystone database.."
    if [[ -f /etc/keystone/keystone.conf.ori ]]; then
      echo "[OSTACK] Orginal config found, create temporary config backup.."
      sed -i.bak -e "551d" /etc/keystone/keystone.conf
      echo "[OSTACK] Setting connection.."
      sed -i "551i connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@controller/keystone" /etc/keystone/keystone.conf
      echo "[OSTACK] Done."
    else
      echo "[OSTACK] Original config not found, create original config backup.."
      sed -i.ori -e "551d" /etc/keystone/keystone.conf
      echo "[OSTACK] Setting connection.."
      sed -i "551i connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@controller/keystone" /etc/keystone/keystone.conf
      echo "[OSTACK] Done."
    fi

    echo "[OSTACK] Configuring keystone token.."
    if [[ -f /etc/keystone/keystone.conf.ori ]]; then
      echo "[OSTACK] Orginal config found, create temporary config backup.."
      sed -i.bak -e "2047d" /etc/keystone/keystone.conf
      echo "[OSTACK] Setting provider.."
      sed -i "2047i provider = fernet" /etc/keystone/keystone.conf
      echo "[OSTACK] Done."
    else
      echo "[OSTACK] Orginal config not found, create original config backup.."
      sed -i.ori -e "2047d" /etc/keystone/keystone.conf
      echo "[OSTACK] Setting provider.."
      sed -i "2047i -l provider = fernet" /etc/keystone/keystone.conf
      echo "[OSTACK] Done."
    fi

    echo "[OSTACK] Populate keystone database.."
    su -s /bin/sh -c "keystone-manage db_sync" keystone

    echo "[OSTACK] Initialize Fernet key repositories.."
    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

    echo "[OSTACK] Bootstraping keystone.."
    keystone-manage bootstrap --bootstrap-password ${KEYSTONE_ADMINPASS} --bootstrap-admin-url http://controller:35357/v3/ --bootstrap-internal-url http://controller:35357/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne

    echo "[OSTACK] Done."
    conf_apache2
  else
    echo "[OSTACK] Chrony is not installed. Execute 'dep_conf_env_controller' first!"
    echo "[OSTACK] Abort."
    exit
  fi
}

conf_apache2() {
  echo "======================================================="
  echo "[OSTACK] Configure HTTP server"
  echo "======================================================="

  if [[ -d /etc/apache2 ]]; then
    echo "[OSTACK] Configuring the Apache HTTP server.."
    if [[ -f /etc/apache2/apache2.conf.ori ]]; then
      echo "[OSTACK] Orginal config found, create temporary config backup.."
      cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak

      echo "[OSTACK] Setting ServerName.."
      cat >> /etc/apache2/apache2.conf <<EOF

# Openstack ServerName
ServerName ${IP_ADDR0_ETH1}
EOF
    else
      echo "[OSTACK] Orginal config not found, creating backup.."
      cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.ori

      echo "[OSTACK] Setting ServerName.."
      cat >> /etc/apache2/apache2.conf <<EOF

# Openstack ServerName
ServerName ${IP_ADDR0_ETH1}
EOF
    fi

    echo "[OSTACK] Restarting apache2.."
    service apache2 restart

    echo "[OSTACK] Removing default SQlite database"
    rm -f /var/lib/keystone/keystone.db

    echo "[OSTACK] Done."
    set_enviroment
  else
    echo "[OSTACK] Chrony is not installed. Execute 'dep_conf_env_controller' first!"
    echo "[OSTACK] Abort."
    exit
  fi
}

set_enviroment() {
  echo "[OSTACK] Creating temp-admin-openrc.."
  cat > ./temp-admin-openrc <<EOF
export OS_USERNAME="admin"
export OS_PASSWORD="${KEYSTONE_ADMINPASS}"
export OS_PROJECT_NAME="admin"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_NAME="Default"
export OS_AUTH_URL="http://controller:35357/v3"
export OS_IDENTITY_API_VERSION=3
EOF

  echo "[OSTACK] Creating admin-openrc to /home/${USERNAME0}.."
  cat > /home/${USERNAME0}/admin-openrc <<EOF
export OS_USERNAME="admin"
export OS_PASSWORD="${KEYSTONE_ADMINPASS}"
export OS_PROJECT_NAME="admin"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_NAME="Default"
export OS_AUTH_URL="http://controller:35357/v3"
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

  echo "[OSTACK] Creating demo-openrc to /home/${USERNAME0}.."
  cat > /home/${USERNAME0}/demo-openrc <<EOF
export OS_USERNAME="demo"
export OS_PASSWORD="${KEYSTONE_ADMINPASS}"
export OS_PROJECT_NAME="demo"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_NAME="Default"
export OS_AUTH_URL="http://controller:5000/v3"
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

  echo "[OSTACK] Done."
}

echo "[OSTACK] CONFIGURING 'keystone' ON '$(hostname)'.."
conf_keystone
