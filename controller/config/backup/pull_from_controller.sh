#!/bin/bash

USR="rohwid"
CTRL="10.122.1.210"
DIR="/home/rohwid/sync_dir/*"

echo "[OSTACK] Cleaning sync files.."
rm etcd keystone.conf apache2.conf

echo "[OSTACK] Pulling from ${CTRL} in ${DIR}.."
rsync -avzh ${USR}@${CTRL}:${DIR} .
