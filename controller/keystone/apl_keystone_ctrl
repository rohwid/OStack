#!/bin/bash

source ../../servers
source ../../services

service_project() {
  echo "======================================================="
  echo "[OSTACK] Create project"
  echo "======================================================="

  echo "[OSTACK] Creating service project.."
  openstack project create --domain default --description "Service Project" service

  echo "[OSTACK] Creating demo project.."
  openstack project create --domain default --description "Demo Project" demo

  echo "[OSTACK] Creating demo user.."
  openstack user create --domain default --password-prompt demo

  echo "[OSTACK] Creatingrole.."
  openstack role create user

  echo "[OSTACK] Add the user role to the demo project and use"
  openstack role add --project demo --user demo user

  echo "[OSTACK] Done."
  verify_keystone
}

verify_keystone() {
  echo "======================================================="
  echo "[OSTACK] Verify keystone"
  echo "======================================================="

  echo "[OSTACK] Removing 'temp-admin-openrc'.."
  rm temp-admin-openrc

  echo "[OSTACK] Unset the temporary OS_AUTH_URL and OS_PASSWORD environment variable.."
  unset OS_AUTH_URL OS_PASSWORD

  echo "[OSTACK] As the admin user, request an authentication token.."
  openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin --os-username admin token issue

  echo "[OSTACK] As the demo user, request an authentication token.."
  openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name demo --os-username demo token issue

  echo "[OSTACK] Done."
}

service_project
