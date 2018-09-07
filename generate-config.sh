#!/bin/bash

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
}

chrony() {
  read -p "Enter NTP server: " NTP
  read -p "Enter management network: " MAN_NET

  echo "[OStack] Configuring NTP with chrony.."

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
}

db() {
  echo "[OStack] Configuring databases.."

  cat > controller/config/99-openstack.cnf <<EOF
[mysqld]
bind-address = ${CTRL}

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
}

memcached() {
  echo "[OStack] Configuring memcached.."

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
}

etcd() {
  echo "[OStack] Configuring etcd.."

  cat > controller/config/etcd <<EOF
## etcd(1) daemon options
## See "/usr/share/doc/etcd/Documentation/configuration.md.gz".

### Member Flags

##### -name
ETCD_NAME="controller"

##### -data-dir
ETCD_DATA_DIR="/var/lib/etcd"

##### -wal-dir
# ETCD_WAL_DIR

##### -snapshot-count
# ETCD_SNAPSHOT_COUNT="10000"

##### -heartbeat-interval
# ETCD_HEARTBEAT_INTERVAL="100"

##### -election-timeout
# ETCD_ELECTION_TIMEOUT="1000"

##### -listen-peer-urls
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"

##### -listen-client-urls
ETCD_LISTEN_CLIENT_URLS="http://${CTRL}:2379"

##### -max-snapshots
# ETCD_MAX_SNAPSHOTS="5"

##### -max-wals
# ETCD_MAX_WALS="5"

##### -cors
# ETCD_CORS

### Clustering Flags
## For an explanation of the various ways to do cluster setup, see:
## /usr/share/doc/etcd/Documentation/clustering.md.gz
##
## The command line parameters starting with -initial-cluster will be
## ignored on subsequent runs of etcd as they are used only during initial
## bootstrap process.

##### -initial-advertise-peer-urls
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${CTRL}:2380"

##### -initial-cluster
ETCD_INITIAL_CLUSTER="controller=http://${CTRL}:2380"

##### -initial-cluster-state
ETCD_INITIAL_CLUSTER_STATE="new"

##### -initial-cluster-token
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"

##### -advertise-client-urls
ETCD_ADVERTISE_CLIENT_URLS="http://${CTRL}:2379"

##### -discovery
# ETCD_DISCOVERY

##### -discovery-srv
# ETCD_DISCOVERY_SRV

##### -discovery-fallback
# ETCD_DISCOVERY_FALLBACK="proxy"

##### -discovery-proxy
# ETCD_DISCOVERY_PROXY

### Proxy Flags

##### -proxy
# ETCD_PROXY="on"

##### -proxy-failure-wait
# ETCD_PROXY_FAILURE_WAIT="5000"

##### -proxy-refresh-interval
# ETCD_PROXY_REFRESH_INTERVAL="30000"

##### -proxy-dial-timeout
# ETCD_PROXY_DIAL_TIMEOUT="1000"

##### -proxy-write-timeout
# ETCD_PROXY_WRITE_TIMEOUT="5000"

##### -proxy-read-timeout
# ETCD_PROXY_READ_TIMEOUT="0"

### Security Flags

##### -ca-file [DEPRECATED]
# ETCD_CA_FILE=""

##### -cert-file
# ETCD_CERT_FILE=""

##### -key-file
# ETCD_KEY_FILE=""

##### -client-cert-auth
# ETCD_CLIENT_CERT_AUTH

##### -trusted-ca-file
# ETCD_TRUSTED_CA_FILE

##### -peer-ca-file [DEPRECATED]
# ETCD_PEER_CA_FILE

##### -peer-cert-file
# ETCD_PEER_CERT_FILE

##### -peer-key-file
# ETCD_PEER_KEY_FILE

##### -peer-client-cert-auth
# ETCD_PEER_CLIENT_CERT_AUTH

##### -peer-trusted-ca-file
# ETCD_PEER_TRUSTED_CA_FILE

### Logging Flags

##### -debug
# ETCD_DEBUG

##### -log-package-levels
# ETCD_LOG_PACKAGE_LEVELS

#### Daemon parameters:
# DAEMON_ARGS=""
EOF
}


echo " "
echo "======================================================="
echo "[OSTACK] Welcome to Configuration Generator"
echo "======================================================="
echo " "

echo "Please answer this question carefully: "
read -p "Number of host (Include controller and compute): " HOST
read -p "Controller IP Address: " CTRL

case "${HOST}" in
    2)  two
        chrony
        db
        memcached
        etcd
        ;;
    3)  three
        chrony
        db
        memcached
        etcd
        ;;
    4)  four
        chrony
        db
        memcached
        etcd
        ;;
    5)  five
        chrony
        db
        memcached
        etcd
        ;;
    *)  echo "Input invalid. Input out of range or not a number."
        echo "Operation aborted."
        exit
esac
