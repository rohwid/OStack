#!/bin/bash

echo "==================================================="
echo "WARNING! This only for development tools."
echo "Make sure you've read and edit this script first!"
echo "==================================================="

USR="rohwid"
CTRL="10.122.1.211"
DIR="/home/rohwid/sync_dir/*"

echo "[OSTACK] Cleaning sync files.."
cd compute/config/backup
rm *

echo "[OSTACK] Pulling from ${CTRL} in ${DIR}.."
rsync -avzh ${USR}@${CTRL}:${DIR} .
