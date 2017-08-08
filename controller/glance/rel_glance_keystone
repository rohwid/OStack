#!/bin/bash

source ../../services
source ../../servers

echo "============================================================"
echo "[OSTACK] RELATING `${SERVICE_NAME2}` WITH `${SERVICE_NAME1}`"
echo "============================================================"

echo "[OSTACK] Exporting admin-openrc.."
./home/${USERNAME0}/admin-openrc

echo "[OSTACK] Exporting admin-openrc.."
openstack user create --domain default --password-prompt ${SERVICE_NAME2}

echo "[OSTACK] Adding admin role.."
openstack role add --project service --user ${SERVICE_NAME2} admin

echo "[OSTACK] Creating the glance service entity.."
openstack service create --name ${SERVICE_NAME2} --description "OpenStack Image" image

echo "[OSTACK] Create public Image service API endpoints.."
openstack endpoint create --region RegionOne image public http://controller:9292

echo "[OSTACK] Create internal Image service API endpoints.."
openstack endpoint create --region RegionOne image internal http://controller:9292

echo "[OSTACK] Create admin Image service API endpoints.."
openstack endpoint create --region RegionOne image admin http://controller:9292
