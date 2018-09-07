#!/bin/bash

source ../services.sh

chrony() {
  echo "======================================================="
  echo "[OSTACK] Configure NTP in controller"
  echo "======================================================="

  read -n1 -r -p "Download opencv-${VERSION}. press ENTER to continue!" ENTER
  
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
  echo "======================================================="
  echo "[OSTACK] Install Openstack Packages"
  echo "======================================================="

  if [[ -f /usr/bin/openstack ]]; then
    config_db
  else
    echo "[OSTACK] Installing Openstack packages.."
    apt install python-openstackclient -y

    config_db
  fi
}

config_db() {
  echo "======================================================="
  echo "[OSTACK] Configure database"
  echo "======================================================="

  if [[ -d /etc/mysql ]]; then
    echo "[OSTACK] MySQL found.."
    if [[ -f /etc/mysql/mariadb.conf.d/99-openstack.cnf ]]; then
      echo "[OSTACK] Backup current configuration.."
      cp /etc/mysql/mariadb.conf.d/99-openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf.bak

      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/
    else
      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/

      echo "[OSTACK] Restarting MySQL.."
      service mysql restart

      echo "[OSTACK] MySQL secure installation.."
      mysql_secure_installation

      echo "[OSTACK] Done."
      rabbit_mq
    fi
  else
    echo "[OSTACK] MySQL not found.."
    echo "[OSTACK] Installing mysql.."
    apt install mariadb-server python-pymysql -y

    if [[ -f /etc/mysql/mariadb.conf.d/99-openstack.cnf ]]; then
      echo "[OSTACK] Backup current configuration.."
      cp /etc/mysql/mariadb.conf.d/99-openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf.bak

      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/
    else
      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/

      echo "[OSTACK] Restarting MySQL.."
      service mysql restart

      echo "[OSTACK] MySQL secure installation.."
      mysql_secure_installation

      echo "[OSTACK] Done."
      rabbit_mq
    fi
  fi
}

rabbit_mq() {
  echo "======================================================="
  echo "[OSTACK] Configure rabbitmq-server"
  echo "======================================================="

  if [[ -d /etc/rabbitmq ]]; then
    echo "[OSTACK] Rabbitmq-server found.."

    echo "[OSTACK] Adding openstack as rabbit user.."
    rabbitmqctl add_user ${MQ_USER} ${MQ_PASS}

    echo "[OSTACK] Granting openstack permission.."
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"

    echo "[OSTACK] restart rabbitmq-server.."
    service rabbitmq-server restart

    echo "[OSTACK] Done."
    memcached
  else
    echo "[OSTACK] Rabbitmq-server not found.."
    echo "[OSTACK] Installing rabbitmq-server.."
    apt install rabbitmq-server -y

    echo "[OSTACK] Adding openstack as rabbit user.."
    rabbitmqctl add_user ${MQ_USER} ${MQ_PASS}

    echo "[OSTACK] Granting openstack permission.."
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"

    echo "[OSTACK] restart rabbitmq-server.."
    service rabbitmq-server restart

    echo "[OSTACK] Done."
    memcached
  fi
}

memcached() {
  echo "======================================================="
  echo "[OSTACK] Configure memcached"
  echo "======================================================="

  if [[ -f /etc/memcached.conf ]]; then
    echo "[OSTACK] Memcached found.."

    if [[ -f /etc/memcached.conf.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      cp /etc/memcached.conf /etc/memcached.conf.bak
      echo "[OSTACK] Configuring memcached.."
      cp ../config/memcached.conf /etc/
    else
      echo "[OSTACK] Backup original configuration.."
      cp /etc/memcached.conf /etc/memcached.conf.ori
      echo "[OSTACK] Configuring memcached.."
      cp ../config/memcached.conf /etc/
    fi

    echo "[OSTACK] Restarting memcached.."
    service memcached restart

    echo "[OSTACK] Done."
    etcd
  else
    echo "[OSTACK] Memcached not found.."
    echo "[OSTACK] Installing memcached.."
    apt install memcached python-memcache -y

    if [[ -f /etc/memcached.conf.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      cp /etc/memcached.conf /etc/memcached.conf.bak
      echo "[OSTACK] Configuring memcached.."
      cp ../config/memcached.conf /etc/
    else
      echo "[OSTACK] Backup original configuration.."
      cp /etc/memcached.conf /etc/memcached.conf.ori
      echo "[OSTACK] Configuring memcached.."
      cp ../config/memcached.conf /etc/
    fi

    echo "[OSTACK] Restarting memcached.."
    service memcached restart

    echo "[OSTACK] Done."
    etcd
  fi
}

etcd() {
  echo "======================================================="
  echo "[OSTACK] Configure etcd"
  echo "======================================================="

  if [[ -f /etc/default/etcd ]]; then
    echo "[OSTACK] Etcd found.."

    if [[ -f /etc/default/etcd.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      cp /etc/default/etcd /etc/default/etcd.bak
      echo "[OSTACK] Configuring etcd.."
      cp ../config/etcd /etc/default/
    else
      echo "[OSTACK] Backup original configuration.."
      cp /etc/default/etcd /etc/default/etcd.ori
      echo "[OSTACK] Configuring etcd.."
      cp ../config/etcd /etc/default/
    fi

    echo "[OSTACK] Restarting etcd.."
    systemctl enable etcd
    systemctl start etcd

    echo "[OSTACK] Done."
  else
    echo "[OSTACK] Etcd not found.."
    echo "[OSTACK] Installing etcd.."
    apt install memcached python-memcache -y

    if [[ -f /etc/default/etcd.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      cp /etc/default/etcd /etc/default/etcd.bak
      echo "[OSTACK] Configuring etcd.."
      cp ../config/etcd /etc/default/
    else
      echo "[OSTACK] Backup original configuration.."
      cp /etc/default/etcd /etc/default/etcd.ori
      echo "[OSTACK] Configuring etcd.."
      cp ../config/etcd /etc/default/
    fi

    echo "[OSTACK] Restarting etcd.."
    systemctl enable etcd
    systemctl start etcd

    echo "[OSTACK] Done."
  fi
}

echo "[OSTACK] CONFIGURING ENVIRONMENT ON '$(hostname)'.."
chrony
