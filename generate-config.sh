#!/bin/bash

source services
source servers

config_file() {
  echo "[OSTACK] Copy service and server config file to controller.."
  cp services controller
  cp servers controller

  echo "[OSTACK] Copy service and server config file to compute.."
  cp services compute
  cp servers compute

  echo "[OSTACK] All config file created."
}

two() {
  read -p "Compute1 IP Address: " COM1

  cat > controller/config/hosts <<EOF
127.0.0.1	localhost

# controller
${CTRL}   controller

# compute1
${COM1}   compute1

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

  cp controller/config/hosts compute/config/hosts

  echo "[OSTACK] Setup ${HOST} host done."
}

three() {
  read -p "Compute1 IP Address: " COM1
  read -p "Compute2 IP Address: " COM2

  cat > controller/config/hosts <<EOF
127.0.0.1	localhost

# controller
${CTRL}   controller

# compute1
${COM1}   compute1

# compute2
${COM2}   compute2

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

  cp controller/config/hosts compute/config/hosts

  echo "[OSTACK] Setup ${HOST} host done."
}

four() {
  read -p "Compute1 IP Address: " COM1
  read -p "Compute2 IP Address: " COM2
  read -p "Compute3 IP Address: " COM3

  cat > controller/config/hosts <<EOF
127.0.0.1	localhost

# controller
${CTRL}   controller

# compute1
${COM1}   compute1

# compute2
${COM2}   compute2

# compute3
${COM3}   compute3

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

  cp controller/config/hosts compute/config/hosts

  echo "[OSTACK] Setup ${HOST} host done."
}

five() {
  read -p "Compute1 IP Address: " COM1
  read -p "Compute2 IP Address: " COM2
  read -p "Compute3 IP Address: " COM3
  read -p "Compute4 IP Address: " COM4

  cat > controller/config/hosts <<EOF
127.0.0.1	localhost

# controller
${CTRL}   controller

# compute1
${COM1}   compute1

# compute2
${COM2}   compute2

# compute3
${COM3}   compute3

# compute4
${COM4}   compute4

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

  cp controller/config/hosts compute/config/hosts

  echo "[OSTACK] Setup ${HOST} host done."
}

chrony() {
  read -p "Enter management network: " MAN_NET

  echo "[OSTACK] Configuring NTP with chrony.."

  cat > controller/config/chrony.conf <<EOF
# Welcome to the chrony configuration file. See chrony.conf(5) for more
# information about usuable directives.

# This will use (up to):
# - 4 sources from ntp.ubuntu.com which some are ipv6 enabled
# - 2 sources from 2.ubuntu.pool.ntp.org which is ipv6 enabled as well
# - 1 source from [01].ubuntu.pool.ntp.org each (ipv4 only atm)
# This means by default, up to 6 dual-stack and up to 2 additional IPv4-only
# sources will be used.
# At the same time it retains some protection against one of the entries being
# down (compare to just using one of the lines). See (LP: #1754358) for the
# discussion.
#
# About using servers from the NTP Pool Project in general see (LP: #104525).
# Approved by Ubuntu Technical Board on 2011-02-08.
# See http://www.pool.ntp.org/join.html for more information.

# NTP server Indonesia
${CHRONICS} iburst

# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /var/lib/chrony/chrony.drift

# Allow to connect other nodes
allow ${MAN_NET}

# Uncomment the following line to turn logging on.
#log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 100.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 1 3
EOF

  cat > compute/config/chrony.conf <<EOF
# Welcome to the chrony configuration file. See chrony.conf(5) for more
# information about usuable directives.

# This will use (up to):
# - 4 sources from ntp.ubuntu.com which some are ipv6 enabled
# - 2 sources from 2.ubuntu.pool.ntp.org which is ipv6 enabled as well
# - 1 source from [01].ubuntu.pool.ntp.org each (ipv4 only atm)
# This means by default, up to 6 dual-stack and up to 2 additional IPv4-only
# sources will be used.
# At the same time it retains some protection against one of the entries being
# down (compare to just using one of the lines). See (LP: #1754358) for the
# discussion.
#
# About using servers from the NTP Pool Project in general see (LP: #104525).
# Approved by Ubuntu Technical Board on 2011-02-08.
# See http://www.pool.ntp.org/join.html for more information.

server controller iburst

# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /var/lib/chrony/chrony.drift

# Uncomment the following line to turn logging on.
#log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 100.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 1 3
EOF

  echo "[OSTACK] Chrony done."
}

db() {
  echo "[OSTACK] Configuring databases.."

  cat > controller/config/99-openstack.cnf <<EOF
[mysqld]
bind-address = ${CTRL}

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
  echo "[OSTACK] Databases done."
}

memcached() {
  echo "[OSTACK] Configuring memcached.."

  cat > controller/config/memcached.conf <<EOF
# memcached default config file
# 2003 - Jay Bonci <jaybonci@debian.org>
# This configuration file is read by the start-memcached script provided as
# part of the Debian GNU/Linux distribution.

# Run memcached as a daemon. This command is implied, and is not needed for the
# daemon to run. See the README.Debian that comes with this package for more
# information.
-d

# Log memcached's output to /var/log/memcached
logfile /var/log/memcached.log

# Be verbose
# -v

# Be even more verbose (print client commands as well)
# -vv

# Start with a cap of 64 megs of memory. It's reasonable, and the daemon default
# Note that the daemon will grow to this size, but does not start out holding this much
# memory
-m 64

# Default connection port is 11211
-p 11211

# Run the daemon as root. The start-memcached will default to running as root if no
# -u command is present in this config file
-u memcache

# Specify which IP address to listen on. The default is to listen on all IP addresses
# This parameter is one of the only security measures that memcached has, so make sure
# it's listening on a firewalled interface.
-l ${CTRL}

# Limit the number of simultaneous incoming connections. The daemon default is 1024
# -c 1024

# Lock down all paged memory. Consult with the README and homepage before you do this
# -k

# Return error when memory is exhausted (rather than removing items)
# -M

# Maximize core file limit
# -r

# Use a pidfile
-P /var/run/memcached/memcached.pid
EOF

  echo "[OSTACK] Memcached done."
}

etcd() {
  echo "[OSTACK] Configuring etcd.."
  echo "[OSTACK] Get etcd configuration file.."
  cp controller/config/backup/etcd.ori controller/config/etcd

  echo "[OSTACK] Configuring etcd.."
  sed -i -e "12d" controller/config/etcd
  sed -i -e '12i ETCD_NAME="controller"' controller/config/etcd
  sed -i -e "16d" controller/config/etcd
  sed -i -e '16i ETCD_DATA_DIR="/var/lib/etcd"' controller/config/etcd
  sed -i -e "52d" controller/config/etcd
  sed -i -e '52i ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"' controller/config/etcd
  sed -i -e "66d" controller/config/etcd
  sed -i -e "66i ETCD_LISTEN_CLIENT_URLS="http://${CTRL}:2379"" controller/config/etcd
  sed -i -e "98d" controller/config/etcd
  sed -i -e "98i ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${CTRL}:2380"" controller/config/etcd
  sed -i -e "105d" controller/config/etcd
  sed -i -e "105i ETCD_INITIAL_CLUSTER="controller=http://${CTRL}:2380"" controller/config/etcd
  sed -i -e "113d" controller/config/etcd
  sed -i -e '113i ETCD_INITIAL_CLUSTER_STATE="new"' controller/config/etcd
  sed -i -e "122d" controller/config/etcd
  sed -i -e '122i ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"' controller/config/etcd
  sed -i -e "133d" controller/config/etcd
  sed -i -e "133i ETCD_ADVERTISE_CLIENT_URLS="http://${CTRL}:2379"" controller/config/etcd

  echo "[OSTACK] Etcd done."
}

keystone() {
  echo "[OSTACK] Get keystone configuration file.."
  cp controller/config/backup/keystone.conf.ori controller/config/keystone.conf

  echo "[OSTACK] Configuring keystone.."
  sed -i -e "721d" controller/config/keystone.conf
  sed -i -e "722i connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@controller/keystone" controller/config/keystone.conf
  sed -i -e '723i \\' controller/config/keystone.conf

  sed -i -e "2935d" controller/config/keystone.conf
  sed -i -e "2935i provider = fernet" controller/config/keystone.conf

  echo "[OSTACK] Get apache2 configuration file.."
  cp controller/config/backup/apache2.conf.ori controller/config/apache2.conf

  echo " " >> controller/config/apache2.conf
  echo "ServerName controller" >> controller/config/apache2.conf

  echo "[OSTACK] Keystone done."
}

glance() {
  echo "[OSTACK] Get glance configuration file.."
  cp controller/config/backup/glance-api.conf.ori controller/config/glance-api.conf

  echo "[OSTACK] Configuring glance-api.."
  sed -i -e "1925d" controller/config/glance-api.conf
  sed -i -e '1925i \\' controller/config/glance-api.conf
  sed -i -e '1926i \\' controller/config/glance-api.conf
  sed -i -e "1926i connection = mysql+pymysql://glance:${GLANCE_DBPASS}@controller/glance" controller/config/glance-api.conf

  sed -i -e '2045i \\' controller/config/glance-api.conf
  sed -i -e '2045i stores = file,http' controller/config/glance-api.conf
  sed -i -e '2046i default_store = file' controller/config/glance-api.conf
  sed -i -e '2047i filesystem_store_datadir = /var/lib/glance/images/' controller/config/glance-api.conf

  sed -i -e '3482i \\' controller/config/glance-api.conf
  sed -i -e '3482i www_authenticate_uri = http://controller:5000' controller/config/glance-api.conf
  sed -i -e '3483i auth_url = http://controller:5000' controller/config/glance-api.conf
  sed -i -e '3484i memcached_servers = controller:11211' controller/config/glance-api.conf
  sed -i -e '3485i auth_type = password' controller/config/glance-api.conf
  sed -i -e '3486i project_domain_name = Default' controller/config/glance-api.conf
  sed -i -e '3487i user_domain_name = Default' controller/config/glance-api.conf
  sed -i -e '3488i project_name = service' controller/config/glance-api.conf
  sed -i -e '3489i username = glance' controller/config/glance-api.conf
  sed -i -e "3490i password = ${GLANCE_ADMINPASS}" controller/config/glance-api.conf

  sed -i -e "4521d" controller/config/glance-api.conf
  sed -i -e '4521i flavor = keystone' controller/config/glance-api.conf

  echo "[OSTACK] Get glance configuration file.."
  cp controller/config/backup/glance-registry.conf.ori controller/config/glance-registry.conf

  echo "[OSTACK] Configuring glance-registry.."
  sed -i -e "1171d" controller/config/glance-registry.conf
  sed -i -e '1171i \\' controller/config/glance-registry.conf
  sed -i -e '1172i \\' controller/config/glance-registry.conf
  sed -i -e "1172i connection = mysql+pymysql://glance:${GLANCE_DBPASS}@controller/glance" controller/config/glance-registry.conf

  sed -i -e '1291i \\' controller/config/glance-registry.conf
  sed -i -e '1291i www_authenticate_uri = http://controller:5000' controller/config/glance-registry.conf
  sed -i -e '1292i auth_url = http://controller:5000' controller/config/glance-registry.conf
  sed -i -e '1293i memcached_servers = controller:11211' controller/config/glance-registry.conf
  sed -i -e '1294i auth_type = password' controller/config/glance-registry.conf
  sed -i -e '1295i project_domain_name = Default' controller/config/glance-registry.conf
  sed -i -e '1296i user_domain_name = Default' controller/config/glance-registry.conf
  sed -i -e '1297i project_name = service' controller/config/glance-registry.conf
  sed -i -e '1298i username = glance' controller/config/glance-registry.conf
  sed -i -e "1299i password = ${GLANCE_ADMINPASS}" controller/config/glance-registry.conf

  sed -i -e "2303d" controller/config/glance-registry.conf
  sed -i -e '2303i flavor = keystone' controller/config/glance-registry.conf

  echo "[OSTACK] Glance done."
}

nova_ctrl() {
  echo "[OSTACK] Get nova configuration file.."
  cp controller/config/backup/nova.conf.ori controller/config/nova.conf

  echo "[OSTACK] Configuring nova.."
  sed -i -e "2d" controller/config/nova.conf
  sed -i -e "4i transport_url = rabbit://openstack:${MQ_PASS}@controller" controller/config/nova.conf
  sed -i -e "5i my_ip = ${IP_M_CTRL}" controller/config/nova.conf # --> will reconfigure later
  sed -i -e "6i use_neutron = true" controller/config/nova.conf
  sed -i -e "7i firewall_driver = nova.virt.firewall.NoopFirewallDriver" controller/config/nova.conf

  sed -i -e "3227d" controller/config/nova.conf
  sed -i -e "3227i auth_strategy = keystone" controller/config/nova.conf
  sed -i -e "3508d" controller/config/nova.conf
  sed -i -e "3508i connection = mysql+pymysql://nova:${NOVA_DBPASS}@controller/nova_api" controller/config/nova.conf

  sed -i -e "4579d" controller/config/nova.conf
  sed -i -e "4579i connection = mysql+pymysql://nova:${NOVA_DBPASS}@controller/nova" controller/config/nova.conf

  sed -i -e "5275d" controller/config/nova.conf
  sed -i -e '5275i api_servers = http://controller:9292' controller/config/nova.conf

  sed -i -e '6055i \\' controller/config/nova.conf
  sed -i -e '6055i auth_url = http://controller:5000/v3' controller/config/nova.conf
  sed -i -e '6056i memcached_servers = controller:11211' controller/config/nova.conf
  sed -i -e '6057i auth_type = password' controller/config/nova.conf
  sed -i -e '6058i project_domain_name = default' controller/config/nova.conf
  sed -i -e '6059i user_domain_name = default' controller/config/nova.conf
  sed -i -e '6060i project_name = service' controller/config/nova.conf
  sed -i -e '6061i username = nova' controller/config/nova.conf
  sed -i -e "6062i password = ${NOVA_ADMINPASS}" controller/config/nova.conf

  sed -i -e "7894d" controller/config/nova.conf
  sed -i -e '7894i lock_path = /var/lib/nova/tmp' controller/config/nova.conf

  sed -i -e '8778i \\' controller/config/nova.conf
  sed -i -e '8778i region_name = RegionOne' controller/config/nova.conf
  sed -i -e '8779i project_domain_name = Default' controller/config/nova.conf
  sed -i -e '8780i project_name = service' controller/config/nova.conf
  sed -i -e '8781i auth_type = password' controller/config/nova.conf
  sed -i -e '8782i user_domain_name = Default' controller/config/nova.conf
  sed -i -e '8783i auth_url = http://controller:5000/v3' controller/config/nova.conf
  sed -i -e '8784i username = placement' controller/config/nova.conf
  sed -i -e "8785i password = ${PLACEMENT_ADMINPASS}" controller/config/nova.conf

  sed -i -e '8927i \\' controller/config/nova.conf
  sed -i -e '8927i [placement_database]' controller/config/nova.conf
  sed -i -e "8928i connection = mysql+pymysql://placement:${PLACEMENT_DBPASS}@controller/placement" controller/config/nova.conf
  sed -i -e "8929d" controller/config/nova.conf

  sed -i -e "9447d" controller/config/nova.conf
  sed -i -e '9447i discover_hosts_in_cells_interval = 300' controller/config/nova.conf

  sed -i -e "10278d" controller/config/nova.conf
  sed -i -e '10278i enabled = true' controller/config/nova.conf

  sed -i -e "10302d" controller/config/nova.conf
  sed -i -e '10302i server_listen = $my_ip' controller/config/nova.conf

  sed -i -e "10315d" controller/config/nova.conf
  sed -i -e '10315i server_proxyclient_address = $my_ip' controller/config/nova.conf

  echo "[OSTACK] Nova in controller done."
}

nova_comp() {
  echo "[OSTACK] Get nova configuration file.."
  cp compute/config/backup/nova.conf.ori compute/config/nova.conf

  echo "[OSTACK] Configuring nova.."
  sed -i -e "2d" compute/config/nova.conf
  sed -i -e "4i transport_url = rabbit://openstack:${MQ_PASS}@controller" compute/config/nova.conf
  sed -i -e "5i my_ip = IP_M_COMP" compute/config/nova.conf # --> will reconfigure later

  sed -i -e '6i use_neutron = true' compute/config/nova.conf
  sed -i -e '7i firewall_driver = nova.virt.firewall.NoopFirewallDriver' compute/config/nova.conf

  sed -i -e "3227d" compute/config/nova.conf
  sed -i -e "3227i auth_strategy = keystone" compute/config/nova.conf

  sed -i -e "5275d" compute/config/nova.conf
  sed -i -e "5275i api_servers = http://controller:9292" compute/config/nova.conf

  sed -i -e '6055i \\' compute/config/nova.conf
  sed -i -e "6055i auth_url = http://controller:5000/v3" compute/config/nova.conf
  sed -i -e "6056i memcached_servers = controller:11211" compute/config/nova.conf
  sed -i -e '6057i auth_type = password' compute/config/nova.conf
  sed -i -e '6058i project_domain_name = default' compute/config/nova.conf
  sed -i -e '6059i user_domain_name = default' compute/config/nova.conf
  sed -i -e '6060i project_name = service' compute/config/nova.conf
  sed -i -e '6061i username = nova' compute/config/nova.conf
  sed -i -e "6062i password = ${NOVA_ADMINPASS}" compute/config/nova.conf

  sed -i -e "7894d" compute/config/nova.conf
  sed -i -e "7894i lock_path = /var/lib/nova/tmp" compute/config/nova.conf

  sed -i -e '8778i \\' compute/config/nova.conf
  sed -i -e "8778i region_name = RegionOne" compute/config/nova.conf
  sed -i -e "8779i project_domain_name = Default" compute/config/nova.conf
  sed -i -e "8780i project_name = service" compute/config/nova.conf
  sed -i -e "8781i auth_type = password" compute/config/nova.conf
  sed -i -e "8782i user_domain_name = Default" compute/config/nova.conf
  sed -i -e "8783i auth_url = http://controller:5000/v3" compute/config/nova.conf
  sed -i -e "8784i username = placement" compute/config/nova.conf
  sed -i -e "8785i password = ${PLACEMENT_ADMINPASS}" compute/config/nova.conf

  sed -i -e "10276d" compute/config/nova.conf
  sed -i -e "10276i enabled = true" compute/config/nova.conf

  sed -i -e "10300d" compute/config/nova.conf
  sed -i -e "10300i server_listen = 0.0.0.0" compute/config/nova.conf

  sed -i -e "10313d" compute/config/nova.conf
  sed -i -e '10313i server_proxyclient_address = $my_ip' compute/config/nova.conf

  echo "[OSTACK] Get nova-compute configuration file.."
  cp compute/config/backup/nova-compute.conf.ori compute/config/nova-compute.conf

  echo "[OSTACK] Configuring nova-compute.."
  sed -i -e '4i virt_type=qemu' compute/config/nova-compute.conf
  sed -i -e "5d" compute/config/nova-compute.conf

  echo "[OSTACK] Nova in compute done."
}

neutron_ctrl() {
  echo "[OSTACK] Get neutron configuration file.."
  cp controller/config/backup/neutron.conf.ori controller/config/neutron.conf

  echo "[OSTACK] Configuring neutron.."
  sed -i -e "3i service_plugins = router" controller/config/neutron.conf
  sed -i -e "4i allow_overlapping_ips = true" controller/config/neutron.conf
  sed -i -e "5i transport_url = rabbit://openstack:${MQ_PASS}@controller" controller/config/neutron.conf
  sed -i -e "6i notify_nova_on_port_status_changes = true" controller/config/neutron.conf
  sed -i -e "7i notify_nova_on_port_data_changes = true" controller/config/neutron.conf
  sed -i -e "33d" controller/config/neutron.conf
  sed -i -e "33i auth_strategy = keystone" controller/config/neutron.conf

  sed -i -e "711d" controller/config/neutron.conf
  sed -i -e "711i connection = mysql+pymysql://neutron:${NEUTRON_DBPASS}@controller/neutron" controller/config/neutron.conf

  sed -i -e '831i \\' controller/config/neutron.conf
  sed -i -e "831i www_authenticate_uri = http://controller:5000" controller/config/neutron.conf
  sed -i -e "832i auth_url = http://controller:5000" controller/config/neutron.conf
  sed -i -e "833i memcached_servers = controller:11211" controller/config/neutron.conf
  sed -i -e "834i auth_type = password" controller/config/neutron.conf
  sed -i -e "835i project_domain_name = default" controller/config/neutron.conf
  sed -i -e "836i user_domain_name = default" controller/config/neutron.conf
  sed -i -e "837i project_name = service" controller/config/neutron.conf
  sed -i -e "838i username = neutron" controller/config/neutron.conf
  sed -i -e "839i password = ${NEUTRON_ADMINPASS}" controller/config/neutron.conf

  sed -i -e '1118i \\' controller/config/neutron.conf
  sed -i -e "1119i auth_url = http://controller:5000" controller/config/neutron.conf
  sed -i -e "1120i auth_type = password" controller/config/neutron.conf
  sed -i -e "1121i project_domain_name = default = controller:11211" controller/config/neutron.conf
  sed -i -e "1122i user_domain_name = default" controller/config/neutron.conf
  sed -i -e "1123i region_name = RegionOne" controller/config/neutron.conf
  sed -i -e "1124i project_name = service" controller/config/neutron.conf
  sed -i -e "1125i username = nova" controller/config/neutron.conf
  sed -i -e "1126i password = ${NOVA_ADMINPASS}" controller/config/neutron.conf

  echo "[OSTACK] Get ml2 configuration file.."
  cp controller/config/backup/ml2_conf.ini.ori controller/config/ml2_conf.ini

  echo "[OSTACK] Configuring ml2.."
  sed -i -e "136d" controller/config/ml2_conf.ini
  sed -i -e "136i type_drivers = flat,vlan,vxlan" controller/config/ml2_conf.ini
  sed -i -e "141d" controller/config/ml2_conf.ini
  sed -i -e "141i tenant_network_types = vxlan" controller/config/ml2_conf.ini
  sed -i -e "145d" controller/config/ml2_conf.ini
  sed -i -e "145i mechanism_drivers = linuxbridge,l2population" controller/config/ml2_conf.ini
  sed -i -e "150d" controller/config/ml2_conf.ini
  sed -i -e "150i extension_drivers = port_security" controller/config/ml2_conf.ini
  sed -i -e "186d" controller/config/ml2_conf.ini
  sed -i -e "186i flat_networks = provider" controller/config/ml2_conf.ini
  sed -i -e "239d" controller/config/ml2_conf.ini
  sed -i -e "239i vni_ranges = 1:1000" controller/config/ml2_conf.ini
  sed -i -e "263i enable_ipset = true" controller/config/ml2_conf.ini
  sed -i -e "264d" controller/config/ml2_conf.ini

  echo "[OSTACK] Get linuxbridge_agent configuration file.."
  cp controller/config/backup/linuxbridge_agent.ini.ori controller/config/linuxbridge_agent.ini

  echo "[OSTACK] Configuring linuxbridge_agent.."
  sed -i -e "157d" controller/config/linuxbridge_agent.ini
  sed -i -e "157i physical_interface_mappings = provider:${IN_P_CTRL}" controller/config/linuxbridge_agent.ini
  sed -i -e "188d" controller/config/linuxbridge_agent.ini
  sed -i -e "188i firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" controller/config/linuxbridge_agent.ini
  sed -i -e "193d" controller/config/linuxbridge_agent.ini
  sed -i -e "193i enable_security_group = true" controller/config/linuxbridge_agent.ini
  sed -i -e "208d" controller/config/linuxbridge_agent.ini
  sed -i -e "208i enable_vxlan = true" controller/config/linuxbridge_agent.ini
  sed -i -e "234d" controller/config/linuxbridge_agent.ini
  sed -i -e "234i local_ip = ${IP_M_CTRL}" controller/config/linuxbridge_agent.ini
  sed -i -e "258d" controller/config/linuxbridge_agent.ini
  sed -i -e "258i l2_population = true" controller/config/linuxbridge_agent.ini

  echo "[OSTACK] Get l3_agent configuration file.."
  cp controller/config/backup/l3_agent.ini.ori controller/config/l3_agent.ini

  echo "[OSTACK] Configuring l3_agent.."
  sed -i -e "16d" controller/config/l3_agent.ini
  sed -i -e "16i interface_driver = linuxbridge" controller/config/l3_agent.ini

  echo "[OSTACK] Get dhcp_agent configuration file.."
  cp controller/config/backup/dhcp_agent.ini.ori controller/config/dhcp_agent.ini

  echo "[OSTACK] Configuring dhcp_agent.."
  sed -i -e "16d" controller/config/dhcp_agent.ini
  sed -i -e "16i interface_driver = linuxbridge" controller/config/dhcp_agent.ini
  sed -i -e "28d" controller/config/dhcp_agent.ini
  sed -i -e "28i dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq" controller/config/dhcp_agent.ini
  sed -i -e "37d" controller/config/dhcp_agent.ini
  sed -i -e "37i enable_isolated_metadata = true" controller/config/dhcp_agent.ini

  echo "[OSTACK] Get metadata_agent configuration file.."
  cp controller/config/backup/metadata_agent.ini.ori controller/config/metadata_agent.ini

  echo "[OSTACK] Configuring metadata_agent.."
  sed -i -e "22d" controller/config/metadata_agent.ini
  sed -i -e "22i nova_metadata_host = controller" controller/config/metadata_agent.ini
  sed -i -e "34d" controller/config/metadata_agent.ini
  sed -i -e "34i metadata_proxy_shared_secret = ${METADATA}" controller/config/metadata_agent.ini

  echo "[OSTACK] Neutron in controller done."
}

neutron_comp() {
  echo "[OSTACK] Get neutron configuration file.."
  cp compute/config/backup/neutron.conf.ori compute/config/neutron.conf

  echo "[OSTACK] Get neutron configuration file.."
  cp compute/config/backup/neutron.conf.ori compute/config/neutron.conf

  echo "[OSTACK] Configuring neutron.."
  sed -i -e '3i \\' compute/config/neutron.conf
  sed -i -e "3i transport_url = rabbit://openstack:${MQ_PASS}@controller" compute/config/neutron.conf

  echo "[OSTACK] Neutron in compute done."
}

openrc() {
  echo "[OSTACK] Creating init-openrc.."

  cat > controller/config/init-openrc <<EOF
export OS_USERNAME=admin
export OS_PASSWORD=${KEYSTONE_ADMINPASS}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF

  echo "[OSTACK] Creating admin-openrc.."

  cat > controller/config/admin-openrc <<EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${KEYSTONE_ADMINPASS}
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

  echo "[OSTACK] Creating demo-openrc.."

  cat > controller/config/demo-openrc <<EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=myproject
export OS_USERNAME=myuser
export OS_PASSWORD=${KEYSTONE_MYUSERPASS}
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

  echo "[OSTACK] All openrc created."
}


echo " "
echo "======================================================="
echo "Welcome to openstack configuration generator"
echo "======================================================="
echo "Please answer this question carefully: "
read -p "Number of host (Include controller and compute): " HOST
read -p "Controller IP Address: " CTRL

case "${HOST}" in
    2)  config_file
        two
        chrony
        db
        memcached
        etcd
        keystone
        glance
        nova_ctrl
        nova_comp
        neutron_ctrl
        openrc
        ;;
    3)  config_file
        three
        chrony
        db
        memcached
        etcd
        keystone
        glance
        nova_ctrl
        nova_comp
        neutron_ctrl
        openrc
        ;;
    4)  config_file
        four
        chrony
        db
        memcached
        etcd
        keystone
        glance
        nova_ctrl
        nova_comp
        neutron_ctrl
        openrc
        ;;
    5)  config_file
        five
        chrony
        db
        memcached
        etcd
        keystone
        glance
        nova_ctrl
        nova_comp
        neutron_ctrl
        openrc
        ;;
    *)  echo "Input invalid. Input out of range or not a number."
        echo "Operation aborted."
        exit
esac

echo "[OSTACK] Done."
