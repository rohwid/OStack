#!/bin/bash

source ../services

db() {
  read -p "Have you register GLANCE to database? [Y/N]: " OPT

  case "${OPT}" in
      Y)  register
          ;;
      y)  register
          ;;
      N)  read -n1 -r -p "Create glance database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';"

          register
          ;;
      n)  read -n1 -r -p "Create glance database on '$(hostname)'. press ENTER to continue!" ENTER

          sudo mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';"

          register
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

register() {
  read -p "Have you register GLANCE to KEYSTONE? [Y/N]: " OPT

  case "${OPT}" in
      Y)  pkg
          ;;
      y)  pkg
          ;;
      N)  read -n1 -r -p "Create glance user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt glance

          read -n1 -r -p "Add admin role to glance user and service project. press ENTER to continue!" ENTER
          openstack role add --project service --user glance admin

          read -n1 -r -p "Create the glance service entity. press ENTER to continue!" ENTER
          openstack service create --name glance --description "OpenStack Image" image

          read -n1 -r -p "Create public Image service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne image public http://controller:9292

          read -n1 -r -p "Create internal Image service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne image internal http://controller:9292

          read -n1 -r -p "Create admin Image service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne image admin http://controller:9292

          pkg
          ;;
      n)  read -n1 -r -p "Create glance user. press ENTER to continue!" ENTER
          openstack user create --domain default --password-prompt glance

          read -n1 -r -p "Add admin role to glance user and service project. press ENTER to continue!" ENTER
          openstack role add --project service --user glance admin

          read -n1 -r -p "Create the glance service entity. press ENTER to continue!" ENTER
          openstack service create --name glance --description "OpenStack Image" image

          read -n1 -r -p "Create public Image service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne image public http://controller:9292

          read -n1 -r -p "Create internal Image service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne image internal http://controller:9292

          read -n1 -r -p "Create admin Image service API endpoints. press ENTER to continue!" ENTER
          openstack endpoint create --region RegionOne image admin http://controller:9292

          pkg
          ;;
      *)  echo "Input invalid. Please choose between [Y/N]."
          echo "Operation aborted."
          exit
  esac
}

pkg() {
  read -n1 -r -p "Install GLANCE package on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ -d /etc/glance ]]; then
    echo "[OSTACK] Glance found.."
    echo "[OSTACK] Creating last configuration backup.."

    if [[ -f /etc/glance/glance-api.conf.ori ]]; then
      echo "[OSTACK] Creating glance-api last configuration backup.."
      sudo cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak
    else
      echo "[OSTACK] Creating glance-api original configuration backup.."
      sudo cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.ori
    fi

    if [[ -f /etc/glance/glance-registry.conf.ori ]]; then
      echo "[OSTACK] Creating glance-registry last configuration backup.."
      sudo cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak
    else
      echo "[OSTACK] Creating glance-registry original configuration backup.."
      sudo cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.ori
    fi
  else
    echo "[OSTACK] Glance not found.."
    echo "[OSTACK] Installing glance.."
    sudo apt install glance -y

    echo "[OSTACK] Creating glance-api configuration backup.."
    sudo cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.ori

    echo "[OSTACK] Creating glance-registry configuration backup.."
    sudo cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.ori
  fi

  echo "[OSTACK] Configuring glance-api.."
  sudo cp ../config/glance-api.conf /etc/glance/glance-api.conf

  echo "[OSTACK] Configuring glance-registry.."
  sudo cp ../config/glance-registry.conf /etc/glance/glance-registry.conf

  echo "[OSTACK] Modifiying glance-api permission.."
  sudo chown root:glance /etc/glance/glance-api.conf
  sudo chmod 644 /etc/glance/glance-api.conf

  echo "[OSTACK] Modifiying glance-registry permission.."
  sudo chown root:glance /etc/glance/glance-registry.conf
  sudo chmod 644 /etc/glance/glance-registry.conf

  read -n1 -r -p "Populate glance database on '$(hostname)'. press ENTER to continue!" ENTER
  sudo su -s /bin/sh -c "glance-manage db_sync" glance

  echo "[OSTACK] Restarting glance-registry.."
  sudo service glance-registry restart

  echo "[OSTACK] Restarting glance-api.."
  sudo service glance-api restart
}

restart_script() {
  read -n1 -r -p "Create glance restart script on '$(hostname)'. press ENTER to continue!" ENTER

  if [[ ! -d ~/restart_script ]];then
    mkdir ~/restart-script
  fi

  echo "[OSTACK] Configuring status-nova.."
  if [[ ! -f ~/restart-script/restart-glance.sh ]];then
    cp ../config/restart-glance.sh ~/restart-script/
  fi

  echo "[OSTACK] Configuring status-glance.."
  if [[ ! -f ~/restart-script/status-glance.sh ]];then
    cp ../config/status-glance.sh ~/restart-script/
  fi
}

verify() {
  read -n1 -r -p "Verify GLANCE service. press ENTER to continue!" ENTER

  echo "[OSTACK] Create glance image directory and download images.."
  if [[ ! -d ~/glance-images ]]; then
    mkdir ~/glance-images
  fi

  if [[ ! -f ~/glance-images/cirros-0.4.0-x86_64-disk.img ]]; then
    wget -P ~/glance-images/ http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
  fi

  read -n1 -r -p "Upload images to glance. press ENTER to continue!" ENTER
  openstack image create "cirros" --file ~/glance-images/cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public

  read -n1 -r -p "Show images in glance. press ENTER to continue!" ENTER
  openstack image list
}

echo " "
echo "==================================================================================="
echo "Configure openstack GLANCE on '$(hostname)'"
echo "==================================================================================="
echo " "
echo "WARNING! Please make sure you have execute '~/ostack-openrc/admin-openrc'"
echo "as enviroment variable before continue this process."
echo " "
echo " $ . ~/ostack-openrc/admin-openrc"
echo " "
echo " OR"
echo " "
echo " $ source ~/ostack-openrc/admin-openrc"
echo " "
echo "==================================================================================="
echo " "
read -n1 -r -p "Press ENTER to continue or CTRL+C to cancel!" ENTER
db
restart_script
verify

echo "[OSTACK] Glance on '$(hostname)' done."
