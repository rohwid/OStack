#!/bin/bash

source ../../servers
source ../../services

read -p "Insert the compute number: " COMPUTE_N

case "${COMPUTE_N}" in
  1) IP_COMPUTE_N="${IP_ADDR1_ETH0}"
      ;;
  2) IP_COMPUTE_N="${IP_ADDR2_ETH0}"
      ;;
  3) IP_COMPUTE_N="${IP_ADDR3_ETH0}"
      ;;
  4) IP_COMPUTE_N="${IP_ADDR4_ETH0}"
      ;;
  5) IP_COMPUTE_N="${IP_ADDR5_ETH0}"
      ;;
  #
  # Add more more compute
  # And keep sync with 'ostack/servers' scripts!
  #
  # n) IP_COMPUTE_N="${IP_ADDR-n_ETH-n}"
  #     ;;
  #
  *) echo "compute${COMPUTE_N} is out of range.."
     echo "Add fix 'ostack/compute/env/conf_hosts' or 'ostack/servers' script!"
     echo "Aborted."
     exit
esac

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

# Compute${COMPUTE_N}
${IP_COMPUTE_N}     compute${COMPUTE_N}

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

# Compute${COMPUTE_N}
${IP_COMPUTE_N}     compute${COMPUTE_N}

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
    echo "[OSTACK] Configuring openstack compute hostname.."
    echo "compute${COMPUTE_N}" > /etc/hostname
  else
    echo "[OSTACK] Backup original configuration.."
    cp /etc/hostname /etc/hostname.ori

    echo "[OSTACK] Configuring openstack compute hostname.."
    echo "compute${COMPUTE_N}" > /etc/hostname
  fi

  echo "[OSTACK] Dont forget to REBOOT this pc to apply all changed!"
  echo "[OSTACK] Finish."
}

config_hosts