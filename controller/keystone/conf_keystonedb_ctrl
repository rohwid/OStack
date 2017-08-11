#!/bin/bash

source ../../services
source ../../servers

echo "======================================================="
echo "[OSTACK] Create ${SERVICE_NAME1} database"
echo "======================================================="

echo "[OSTACK] CONFIGURING '${SERVICE_NAME1}' DATABASE ON '$(hostname)'.."

mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE ${SERVICE_NAME1}; GRANT ALL PRIVILEGES ON ${SERVICE_NAME1}.* TO '${SERVICE_NAME1}'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'; GRANT ALL PRIVILEGES ON ${SERVICE_NAME1}.* TO '${SERVICE_NAME1}'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';"

echo "[OSTACK] Done."
