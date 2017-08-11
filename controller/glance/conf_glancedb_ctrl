#!/bin/bash

source ../../services
source ../../servers

echo "[OSTACK] CONFIGURING `${SERVICE_NAME2}` DATABASE ON `$(hostname)`.."

echo "======================================================="
echo "[OSTACK] Create ${SERVICE_NAME2} database"
echo "======================================================="

mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE ${SERVICE_NAME2}; GRANT ALL PRIVILEGES ON ${SERVICE_NAME2}.* TO '${SERVICE_NAME2}'@'localhost' IDENTIFIED BY '${GLANCE_DBPASS}'; GRANT ALL PRIVILEGES ON ${SERVICE_NAME2}.* TO '${SERVICE_NAME2}'@'%' IDENTIFIED BY '${GLANCE_DBPASS}';"
