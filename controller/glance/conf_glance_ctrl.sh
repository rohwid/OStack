#!/bin/bash

source ../../services
source ../../servers

conf_glance() {
  echo "======================================================="
  echo "[OSTACK] Configure ${SERVICE_NAME2}"
  echo "======================================================="

  echo "[OSTACK] Configuring ${SERVICE_NAME2} database.."
  sed -i.bak -e "605d" /etc/${SERVICE_NAME2}/${SERVICE_NAME2}-api.conf
  sed -i "605i -l connection = mysql+pymysql://${SERVICE_NAME2}:${GLANCE_DBPASS}@controller/${SERVICE_NAME2}" /etc/${SERVICE_NAME2}/${SERVICE_NAME2}-api.conf
}

echo "[OSTACK] CONFIGURING `${SERVICE_NAME2}` ON `$(hostname)`.."
conf_glance
