#!/bin/bash

source controller/services

two() {
  read -p "Compute1 IP Address: " COM1

  cat > controller/config/hosts <<EOF
127.0.0.1	localhost

# controller
${CTRL}	controller

# compute1
${COM1} compute1

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
${CTRL}	controller

# compute1
${COM1} compute1

# compute2
${COM2} compute2

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
${CTRL}	controller

# compute1
${COM1} compute1

# compute2
${COM2} compute2

# compute3
${COM3} compute3

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
${CTRL}	controller

# compute1
${COM1} compute1

# compute2
${COM2} compute2

# compute3
${COM3} compute3

# compute4
${COM4} compute4

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
  read -p "Enter NTP server: " NTP
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
${NTP} iburst

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
  cp controller/config/backup/etcd controller/config/

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
  cp controller/config/backup/keystone.conf controller/config/

  echo "[OSTACK] Orginal config found, create temporary config backup.."
  sed -i -e "721d" controller/config/keystone.conf

  echo "[OSTACK] Configuring keystone.."
  sed -i -e "722i connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@controller/keystone" controller/config/keystone.conf
  sed -i -e '723i \\' controller/config/keystone.conf
  sed -i -e "2935d" controller/config/keystone.conf
  sed -i -e "2935i provider = fernet" controller/config/keystone.conf

  echo "[OSTACK] Get apache2 configuration file.."
  cp controller/config/backup/apache2.conf controller/config/apache2.conf

  echo " " >> controller/config/apache2.conf
  echo "ServerName controller" >> controller/config/apache2.conf

  echo "[OSTACK] Keystone done."
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
}

echo "======================================================="
echo "Welcome to openstack configuration generator"
echo "======================================================="
echo "Please answer this question carefully: "
read -p "Number of host (Include controller and compute): " HOST
read -p "Controller IP Address: " CTRL

case "${HOST}" in
    2)  two
        chrony
        db
        memcached
        etcd
        keystone
        openrc
        ;;
    3)  three
        chrony
        db
        memcached
        etcd
        keystone
        openrc
        ;;
    4)  four
        chrony
        db
        memcached
        etcd
        keystone
        openrc
        ;;
    5)  five
        chrony
        db
        memcached
        etcd
        keystone
        openrc
        ;;
    *)  echo "Input invalid. Input out of range or not a number."
        echo "Operation aborted."
        exit
esac
