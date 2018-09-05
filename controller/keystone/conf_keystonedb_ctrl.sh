#!/bin/bash

source ../../services

echo "======================================================="
echo "[OSTACK] Create keystone database"
echo "======================================================="

echo "[OSTACK] CONFIGURING 'keystone' DATABASE ON '$(hostname)'.."

mysql --user="${MYSQL_USER}" --password="${MYSQL_PASS}" --execute="CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DBPASS}'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DBPASS}';"

echo "[OSTACK] Done."
