#!/bin/bash

source ../services

chrony() {
  read -n1 -r -p "Install and configure NTP with chrony on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/chrony ]]; then
    echo "[OSTACK] Chrony found.."

    if [[ -f /etc/chrony/chrony.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
    else
      echo "[OSTACK] Creating original configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori
    fi
  else
    echo "[OSTACK] Chrony not found.."
    echo "[OSTACK] Installing chrony.."
    sudo apt install chrony -y

    if [[ -f /etc/chrony/chrony.conf.ori ]]; then
      echo "[OSTACK] Creating last configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
    else
      echo "[OSTACK] Creating original configuration backup.."
      sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.ori
    fi
  fi

  echo "[OSTACK] Configuring NTP with chrony.."
  sudo cp ../config/chrony.conf /etc/chrony/

  echo "[OSTACK] Modifiying chrony permission.."
  sudo chown root:root /etc/chrony/chrony.conf
  sudo chmod 644 /etc/chrony/chrony.conf

  echo "[OSTACK] Restarting chrony.."
  sudo service chrony stop
  sudo chronyd -q "server ${CHRONICS} iburst"
  sudo service chrony start

  echo "[OSTACK] Done."
  ostack_pkg
}

ostack_pkg() {
  read -n1 -r -p "Install openstack package on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -f /usr/bin/openstack ]]; then
    config_db
  else
    echo "[OSTACK] Installing Openstack packages.."
    sudo apt install python-openstackclient -y

    config_db
  fi
}

config_db() {
  read -n1 -r -p "Install and configure openstack databases on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/mysql ]]; then
    echo "[OSTACK] MySQL found.."
    if [[ -f /etc/mysql/mariadb.conf.d/99-openstack.cnf ]]; then
      echo "[OSTACK] Backup current configuration.."
      sudo cp /etc/mysql/mariadb.conf.d/99-openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf.bak

      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      sudo cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/

      echo "[OSTACK] Modifiying openstack databases permission.."
      sudo chown root:root /etc/mysql/mariadb.conf.d/99-openstack.cnf
      sudo chmod 644 /etc/mysql/mariadb.conf.d/99-openstack.cnf

      echo "[OSTACK] Restarting MySQL.."
      sudo service mysql restart
    else
      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      sudo cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/

      echo "[OSTACK] Modifiying openstack databases permission.."
      sudo chown root:root /etc/mysql/mariadb.conf.d/99-openstack.cnf
      sudo chmod 644 /etc/mysql/mariadb.conf.d/99-openstack.cnf

      echo "[OSTACK] Restarting MySQL.."
      sudo service mysql restart

      echo "[OSTACK] MySQL secure installation.."
      sudo mysql_secure_installation
    fi
  else
    echo "[OSTACK] MySQL not found.."
    echo "[OSTACK] Installing mysql.."
    sudo apt install mariadb-server python-pymysql -y

    if [[ -f /etc/mysql/mariadb.conf.d/99-openstack.cnf ]]; then
      echo "[OSTACK] Backup current configuration.."
      sudo cp /etc/mysql/mariadb.conf.d/99-openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf.bak

      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      sudo cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/

      echo "[OSTACK] Modifiying openstack databases permission.."
      sudo chown root:root /etc/mysql/mariadb.conf.d/99-openstack.cnf
      sudo chmod 644 /etc/mysql/mariadb.conf.d/99-openstack.cnf

      echo "[OSTACK] Restarting MySQL.."
      sudo service mysql restart

      echo "[OSTACK] MySQL secure installation.."
      sudo mysql_secure_installation
    else
      echo "[OSTACK] Creating openstack mysql configuration for openstack.."
      sudo cp ../config/99-openstack.cnf /etc/mysql/mariadb.conf.d/

      echo "[OSTACK] Modifiying openstack databases permission.."
      sudo chown root:root /etc/mysql/mariadb.conf.d/99-openstack.cnf
      sudo chmod 644 /etc/mysql/mariadb.conf.d/99-openstack.cnf

      echo "[OSTACK] Restarting MySQL.."
      sudo service mysql restart

      echo "[OSTACK] MySQL secure installation.."
      sudo mysql_secure_installation
    fi
  fi

  echo "[OSTACK] Database done."
}

rabbit_mq() {
  read -n1 -r -p "Install and configure RabbitMQ on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/rabbitmq ]]; then
    echo "[OSTACK] Rabbitmq-server found.."

    echo "[OSTACK] Adding openstack as rabbit user.."
    sudo rabbitmqctl add_user ${MQ_USER} ${MQ_PASS}

    echo "[OSTACK] Granting openstack permission.."
    sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"

    echo "[OSTACK] restart rabbitmq-server.."
    sudo service rabbitmq-server restart

    echo "[OSTACK] RabbitMQ done."
  else
    echo "[OSTACK] Rabbitmq-server not found.."
    echo "[OSTACK] Installing rabbitmq-server.."
    sudo apt install rabbitmq-server -y

    echo "[OSTACK] Adding openstack as rabbit user.."
    sudo rabbitmqctl add_user ${MQ_USER} ${MQ_PASS}

    echo "[OSTACK] Granting openstack permission.."
    sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"

    echo "[OSTACK] restart rabbitmq-server.."
    sudo service rabbitmq-server restart

    echo "[OSTACK] RabbitMQ done."
  fi
}

memcached() {
  read -n1 -r -p "Install and configure memcached on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -f /etc/memcached.conf ]]; then
    echo "[OSTACK] Memcached found.."

    if [[ -f /etc/memcached.conf.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      sudo cp /etc/memcached.conf /etc/memcached.conf.bak
    else
      echo "[OSTACK] Backup original configuration.."
      sudo cp /etc/memcached.conf /etc/memcached.conf.ori
    fi
  else
    echo "[OSTACK] Memcached not found.."
    echo "[OSTACK] Installing memcached.."
    sudo apt install memcached python-memcache -y

    if [[ -f /etc/memcached.conf.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      sudo cp /etc/memcached.conf /etc/memcached.conf.bak
    else
      echo "[OSTACK] Backup original configuration.."
      sudo cp /etc/memcached.conf /etc/memcached.conf.ori
    fi
  fi

  echo "[OSTACK] Configuring memcached.."
  sudo cp ../config/memcached.conf /etc/

  echo "[OSTACK] Modifiying memcached permission.."
  sudo chown root:root /etc/memcached.conf
  sudo chmod 644 /etc/memcached.conf

  echo "[OSTACK] Restarting memcached.."
  sudo service memcached restart

  echo "[OSTACK] Memcached done."
}

etcd() {
  read -n1 -r -p "Install and configure etcd on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -f /etc/default/etcd ]]; then
    echo "[OSTACK] Etcd found.."

    if [[ -f /etc/default/etcd.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      sudo cp /etc/default/etcd /etc/default/etcd.bak
    else
      echo "[OSTACK] Backup original configuration.."
      sudo cp /etc/default/etcd /etc/default/etcd.ori
    fi

  else
    echo "[OSTACK] Etcd not found.."
    echo "[OSTACK] Installing etcd.."
    sudo apt install etcd -y

    if [[ -f /etc/default/etcd.ori ]]; then
      echo "[OSTACK] Backup current configuration.."
      sudo cp /etc/default/etcd /etc/default/etcd.bak
    else
      echo "[OSTACK] Backup original configuration.."
      sudo cp /etc/default/etcd /etc/default/etcd.ori
    fi

  fi

  echo "[OSTACK] Configuring etcd.."
  sudo cp ../config/etcd /etc/default/

  echo "[OSTACK] Modifiying openstack databases permission.."
  sudo chown root:root /etc/default/etcd
  sudo chmod 644 /etc/default/etcd

  echo "[OSTACK] Restarting etcd.."
  sudo systemctl enable etcd
  sudo systemctl start etcd

  echo "[OSTACK] Etcd done."
}

echo " "
echo "======================================================="
echo "Configure ENVIRONMENT on '$(hostname)'"
echo "======================================================="
echo " "
chrony
config_db
rabbit_mq
memcached
etcd

echo "[OSTACK] Done done."
