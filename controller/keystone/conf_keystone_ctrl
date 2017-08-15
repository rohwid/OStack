#!/bin/bash

source ../../services
source ../../servers

conf_keystone() {
  echo "======================================================="
  echo "[OSTACK] Configure ${SERVICE_NAME1}"
  echo "======================================================="

  # TO DO, check configuration on server!

  if [[ -d /etc/${SERVICE_NAME1} ]]; then
    echo "[OSTACK] Configuring ${SERVICE_NAME1} database.."
    if [[ -f /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf.ori ]]; then
      echo "[OSTACK] Orginal config found, create temporary config backup.."
      sed -i.bak -e "551d" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Setting connection.."
      sed -i "551i connection = mysql+pymysql://${SERVICE_NAME1}:${KEYSTONE_DBPASS}@controller/${SERVICE_NAME1}" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Done."
    else
      echo "[OSTACK] Original config not found, create original config backup.."
      sed -i.ori -e "551d" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Setting connection.."
      sed -i "551i connection = mysql+pymysql://${SERVICE_NAME1}:${KEYSTONE_DBPASS}@controller/${SERVICE_NAME1}" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Done."
    fi

    echo "[OSTACK] Configuring ${SERVICE_NAME1} token.."
    if [[ -f /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf.ori ]]; then
      echo "[OSTACK] Orginal config found, create temporary config backup.."
      sed -i.bak -e "2047d" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Setting provider.."
      sed -i "2047i provider = fernet" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Done."
    else
      echo "[OSTACK] Orginal config not found, create original config backup.."
      sed -i.ori -e "2047d" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Setting provider.."
      sed -i "2047i -l provider = fernet" /etc/${SERVICE_NAME1}/${SERVICE_NAME1}.conf
      echo "[OSTACK] Done."
    fi

    echo "[OSTACK] Populate ${SERVICE_NAME1} database.."
    su -s /bin/sh -c "keystone-manage db_sync" ${SERVICE_NAME1}

    echo "[OSTACK] Initialize Fernet key repositories.."
    keystone-manage fernet_setup --keystone-user ${SERVICE_NAME1} --keystone-group ${SERVICE_NAME1}
    keystone-manage credential_setup --keystone-user ${SERVICE_NAME1} --keystone-group ${SERVICE_NAME1}

    echo "[OSTACK] Bootstraping ${SERVICE_NAME1}.."
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

echo "[OSTACK] CONFIGURING '${SERVICE_NAME1}' ON '$(hostname)'.."
conf_keystone
