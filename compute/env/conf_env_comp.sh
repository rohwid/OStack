#!/bin/bash

chrony() {
  echo "======================================================="
  echo "[OSTACK] Configure NTP chrony.."
  echo "======================================================="

  if [[ -d /etc/chrony ]]; then
    echo "[OStack] Chrony found.."

    echo "[OSTACK] Backup current configuration.."
    cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

    cat >> /etc/chrony/chrony.conf <<EOF

# server NTP from controller
server controller iburst

EOF

    service chrony restart
  else
    echo "[OSTACK] Chrony is not installed. Execute `dep_conf_env_compute` first.. "
    exit
  fi
}

echo "[OSTACK] CONFIGURING `${SERVICE_NAME0}` ON `$(hostname)`.."
chrony