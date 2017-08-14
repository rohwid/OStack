#!/bin/bash

source ../../servers
source ../../services

config_hosts() {
  echo "======================================================="
  echo "[OSTACK] Configure controller hosts"
  echo "======================================================="

  if [[ -f /etc/hosts.ori ]]; then
    echo "[OSTACK] Configuring openstack controller hosts.."
    cat > /etc/hosts <<EOF
127.0.0.1       localhost

# Controller
${IP_ADDR0_ETH0}    controller

# Compute1
${IP_ADDR1_ETH0}    compute1

# Add more compute..
#n.n.n.n             compute-n

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
  else
    echo "[OSTACK] Backup original configuration.."
    cp /etc/hosts /etc/hosts.ori

    echo "[OSTACK] Configuring openstack controller hosts.."
    cat > /etc/hosts <<EOF
127.0.0.1       localhost

# Controller
${IP_ADDR0_ETH0}    controller

# Compute1
${IP_ADDR1_ETH0}    compute1

# Add more compute..
#n.n.n.n             compute(n)

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
  fi

  echo "[OSTACK] Done."
  config_hostname
}

config_hostname() {
  echo "======================================================="
  echo "[OSTACK] Configure controller hostname"
  echo "======================================================="

  if [[ -f /etc/hostname.ori ]]; then
    echo "[OSTACK] Configuring openstack controller hostname.."
    echo "controller" > /etc/hostname
  else
    echo "[OSTACK] Backup original configuration.."
    cp /etc/hostname /etc/hostname.ori

    echo "[OSTACK] Configuring openstack controller hosts.."
    echo "controller" > /etc/hostname
  fi

  echo "[OSTACK] Done."
  do_reboot
}

do_reboot() {
  read -n1 -r -p "Reboot to apply all changes. Press ENTER to reboot!" ENTER

  if [[ $ENTER=\n ]]; then
    reboot
  else
    echo "[OSTACK] This server need to reboot. Please reboot to apply all changes!"
    echo "[OSTACK] Finish."
  fi
}

config_hosts
