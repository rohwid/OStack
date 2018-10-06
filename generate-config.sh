#!/bin/bash

source services
source servers

hosts() {
  read -p "Number of Compute: " COMP_NUM

  echo "[OSTACK] Configuring hosts for controller.."
  cat > controller/config/hosts <<EOF
127.0.0.1	localhost

# Controller
${IP_MAN_CTRL}   controller

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

  echo "[OSTACK] Configuring servers.."
cat > servers <<EOF
## CONTROLLER

# Management
IN_M_CTRL="${IN_MAN_CTRL}"
IP_M_CTRL="${IP_MAN_CTRL}"

# Provider
IN_P_CTRL="${IN_PRO_CTRL}"
IP_P_CTRL="${IP_PRO_CTRL}"

## COMPUTE
NUM="${COMP_NUM}"

##
EOF

  i=0
  init_host_line=6
  init_srv_line=14

  while [ $i -lt $COMP_NUM ]; do
    read -p "Compute$(($i+1)) management Network Interface [eth0, enp3s0f0]: " IN_M_COMP
    read -p "Compute$(($i+1)) management IP address [192.168.1.1]: " IP_M_COMP
    read -p "Compute$(($i+1)) provider Network Interface [eth0, enp3s0f0]: " IN_P_COMP
    read -p "Compute$(($i+1)) provider IP address [10.122.1.1]: " IP_P_COMP
    sed -i -e "${init_host_line}i \\\n" controller/config/hosts
    sed -i -e "${init_host_line}i # Compute$(($i+1))" controller/config/hosts
    sed -i -e "$(($init_host_line+1))i ${IP_M_COMP}   compute$(($i+1))" controller/config/hosts
    sed -i -e "$((${init_host_line}+2))d" controller/config/hosts

    sed -i -e "${init_srv_line}i \\\n" servers
    sed -i -e "$(($init_srv_line))i # Compute$(($i+1)) - Management" servers
    sed -i -e "$(($init_srv_line+1))i IN_M_COMP$(($i+1))="'"'${IN_M_COMP}'"'"" servers
    sed -i -e "$(($init_srv_line+2))i IP_M_COMP$(($i+1))="'"'${IP_M_COMP}'"'"" servers
    sed -i -e "$(($init_srv_line+4))i # Compute$(($i+1)) - Provider" servers
    sed -i -e "$(($init_srv_line+5))i IN_P_COMP$(($i+1))="'"'${IN_P_COMP}'"'"" servers
    sed -i -e "$(($init_srv_line+6))i IP_P_COMP$(($i+1))="'"'${IP_P_COMP}'"'"" servers
    sed -i -e "$(($init_srv_line+7))i \\\n" servers
    sed -i -e "$(($init_srv_line+10+$i))d" servers

    let init_host_line=init_host_line+3
    let init_srv_line=init_srv_line+8
    let i=i+1
  done

  echo "[OSTACK] Configuring hosts for compute.."
  cp controller/config/hosts compute/config/hosts

  echo "[OSTACK] Setup ${COMP_NUM} host done."
}

chrony() {
  echo "[OSTACK] Get chrony configuration file.."
  cp controller/config/backup/chrony.conf.ori controller/config/chrony.conf

  echo "[OSTACK] Configuring NTP with chrony.."
  sed -i -e '17i \\' controller/config/chrony.conf
  sed -i -e "18d" controller/config/chrony.conf
  sed -i -e "18d" controller/config/chrony.conf
  sed -i -e "18d" controller/config/chrony.conf
  sed -i -e "18d" controller/config/chrony.conf
  sed -i -e "18i server ${CHRONICS} iburst" controller/config/chrony.conf

  sed -i -e '30i \\' controller/config/chrony.conf
  sed -i -e "31i allow ${MAN_NET}" controller/config/chrony.conf

  echo "[OSTACK] Configuring chrony for compute.."
  echo "[OSTACK] Get chrony configuration file.."
  cp compute/config/backup/chrony.conf.ori compute/config/chrony.conf

  echo "[OSTACK] Configuring NTP with chrony.."
  sed -i -e '17i \\' compute/config/chrony.conf
  sed -i -e "18d" compute/config/chrony.conf
  sed -i -e "18d" compute/config/chrony.conf
  sed -i -e "18d" compute/config/chrony.conf
  sed -i -e "18d" compute/config/chrony.conf
  sed -i -e "18i server controller iburst" compute/config/chrony.conf

  echo "[OSTACK] Chrony done."
}

db() {
  echo "[OSTACK] Configuring databases.."

  cat > controller/config/99-openstack.cnf <<EOF
[mysqld]
bind-address = ${IP_M_CTRL}

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
  echo "[OSTACK] Databases done."
}

memcached() {
  echo "[OSTACK] Get memcached configuration file.."
  cp controller/config/backup/memcached.conf.ori controller/config/memcached.conf

  echo "[OSTACK] Configuring memcached.."
  sed -i -e "35d" controller/config/memcached.conf
  sed -i -e "35i -l ${IP_MAN_CTRL}" controller/config/memcached.conf

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
  sed -i -e "66i ETCD_LISTEN_CLIENT_URLS="http://${IP_MAN_CTRL}:2379"" controller/config/etcd
  sed -i -e "98d" controller/config/etcd
  sed -i -e "98i ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${IP_MAN_CTRL}:2380"" controller/config/etcd
  sed -i -e "105d" controller/config/etcd
  sed -i -e "105i ETCD_INITIAL_CLUSTER="controller=http://${IP_MAN_CTRL}:2380"" controller/config/etcd
  sed -i -e "113d" controller/config/etcd
  sed -i -e '113i ETCD_INITIAL_CLUSTER_STATE="new"' controller/config/etcd
  sed -i -e "122d" controller/config/etcd
  sed -i -e '122i ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"' controller/config/etcd
  sed -i -e "133d" controller/config/etcd
  sed -i -e "133i ETCD_ADVERTISE_CLIENT_URLS="http://${IP_MAN_CTRL}:2379"" controller/config/etcd

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

  echo "[OSTACK] Configuring nova in controller.."
  sed -i -e "2d" controller/config/nova.conf
  sed -i -e "4i transport_url = rabbit://openstack:${MQ_PASS}@controller" controller/config/nova.conf
  sed -i -e "5i my_ip = ${IP_MAN_CTRL}" controller/config/nova.conf
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

  sed -i -e '7567i \\' controller/config/nova.conf
  sed -i -e '7567i url = http://controller:9696' controller/config/nova.conf
  sed -i -e '7568i auth_url = http://controller:5000' controller/config/nova.conf
  sed -i -e '7569i auth_type = password' controller/config/nova.conf
  sed -i -e '7570i project_domain_name = default' controller/config/nova.conf
  sed -i -e '7571i user_domain_name = default' controller/config/nova.conf
  sed -i -e '7572i region_name = RegionOne' controller/config/nova.conf
  sed -i -e '7573i project_name = service' controller/config/nova.conf
  sed -i -e '7574i username = neutron' controller/config/nova.conf
  sed -i -e "7575i password = ${NEUTRON_ADMINPASS}" controller/config/nova.conf
  sed -i -e '7576i service_metadata_proxy = true' controller/config/nova.conf
  sed -i -e "7577i metadata_proxy_shared_secret = ${METADATA}" controller/config/nova.conf

  sed -i -e "7906d" controller/config/nova.conf
  sed -i -e '7906i lock_path = /var/lib/nova/tmp' controller/config/nova.conf

  sed -i -e '8790i \\' controller/config/nova.conf
  sed -i -e '8790i region_name = RegionOne' controller/config/nova.conf
  sed -i -e '8791i project_domain_name = Default' controller/config/nova.conf
  sed -i -e '8792i project_name = service' controller/config/nova.conf
  sed -i -e '8793i auth_type = password' controller/config/nova.conf
  sed -i -e '8794i user_domain_name = Default' controller/config/nova.conf
  sed -i -e '8795i auth_url = http://controller:5000/v3' controller/config/nova.conf
  sed -i -e '8796i username = placement' controller/config/nova.conf
  sed -i -e "8797i password = ${PLACEMENT_ADMINPASS}" controller/config/nova.conf

  sed -i -e '8939i \\' controller/config/nova.conf
  sed -i -e '8939i [placement_database]' controller/config/nova.conf
  sed -i -e "8940i connection = mysql+pymysql://placement:${PLACEMENT_DBPASS}@controller/placement" controller/config/nova.conf
  sed -i -e "8941d" controller/config/nova.conf

  sed -i -e "9459d" controller/config/nova.conf
  sed -i -e '9459i discover_hosts_in_cells_interval = 300' controller/config/nova.conf

  sed -i -e "10290d" controller/config/nova.conf
  sed -i -e '10290i enabled = true' controller/config/nova.conf

  sed -i -e "10314d" controller/config/nova.conf
  sed -i -e '10314i server_listen = $my_ip' controller/config/nova.conf

  sed -i -e "10327d" controller/config/nova.conf
  sed -i -e '10327i server_proxyclient_address = $my_ip' controller/config/nova.conf

  echo "[OSTACK] Nova in controller done."
}

nova_comp() {
  echo "[OSTACK] Get nova configuration file.."
  cp compute/config/backup/nova.conf.ori compute/config/nova.conf

  echo "[OSTACK] Configuring nova in compute.."
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

  sed -i -e '7567i \\' compute/config/nova.conf
  sed -i -e '7567i url = http://controller:9696' compute/config/nova.conf
  sed -i -e '7568i auth_url = http://controller:5000' compute/config/nova.conf
  sed -i -e '7569i auth_type = password' compute/config/nova.conf
  sed -i -e '7570i project_domain_name = default' compute/config/nova.conf
  sed -i -e '7571i user_domain_name = default' compute/config/nova.conf
  sed -i -e '7572i region_name = RegionOne' compute/config/nova.conf
  sed -i -e '7573i project_name = service' compute/config/nova.conf
  sed -i -e '7574i username = neutron' compute/config/nova.conf
  sed -i -e "7575i password = ${NEUTRON_ADMINPASS}" compute/config/nova.conf

  sed -i -e "7904d" compute/config/nova.conf
  sed -i -e "7904i lock_path = /var/lib/nova/tmp" compute/config/nova.conf

  sed -i -e '8788i \\' compute/config/nova.conf
  sed -i -e '8788i region_name = RegionOne' compute/config/nova.conf
  sed -i -e '8789i project_domain_name = Default' compute/config/nova.conf
  sed -i -e '8790i project_name = service' compute/config/nova.conf
  sed -i -e '8791i auth_type = password' compute/config/nova.conf
  sed -i -e '8792i user_domain_name = Default' compute/config/nova.conf
  sed -i -e '8793i auth_url = http://controller:5000/v3' compute/config/nova.conf
  sed -i -e '8794i username = placement' compute/config/nova.conf
  sed -i -e "8795i password = ${PLACEMENT_ADMINPASS}" compute/config/nova.conf

  sed -i -e "10286d" compute/config/nova.conf
  sed -i -e "10286i enabled = true" compute/config/nova.conf

  sed -i -e "10310d" compute/config/nova.conf
  sed -i -e "10310i server_listen = 0.0.0.0" compute/config/nova.conf

  sed -i -e "10323d" compute/config/nova.conf
  sed -i -e '10323i server_proxyclient_address = $my_ip' compute/config/nova.conf

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

  echo "[OSTACK] Configuring neutron in controller.."
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
  sed -i -e "157i physical_interface_mappings = provider:${IN_PRO_CTRL}" controller/config/linuxbridge_agent.ini
  sed -i -e "188d" controller/config/linuxbridge_agent.ini
  sed -i -e "188i firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" controller/config/linuxbridge_agent.ini
  sed -i -e "193d" controller/config/linuxbridge_agent.ini
  sed -i -e "193i enable_security_group = true" controller/config/linuxbridge_agent.ini
  sed -i -e "208d" controller/config/linuxbridge_agent.ini
  sed -i -e "208i enable_vxlan = true" controller/config/linuxbridge_agent.ini
  sed -i -e "234d" controller/config/linuxbridge_agent.ini
  sed -i -e "234i local_ip = ${IP_MAN_CTRL}" controller/config/linuxbridge_agent.ini
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

  echo "[OSTACK] Configuring neutron in compute.."
  sed -i -e "3i transport_url = rabbit://openstack:${MQ_PASS}@controller" compute/config/neutron.conf
  sed -i -e "29d" compute/config/neutron.conf
  sed -i -e "29i auth_strategy = keystone" compute/config/neutron.conf
  sed -i -e '826i \\' compute/config/neutron.conf
  sed -i -e '826i \\' compute/config/neutron.conf
  sed -i -e "827i www_authenticate_uri = http://controller:5000" compute/config/neutron.conf
  sed -i -e "828i auth_url = http://controller:5000" compute/config/neutron.conf
  sed -i -e "829i memcached_servers = controller:11211" compute/config/neutron.conf
  sed -i -e "830i auth_type = password" compute/config/neutron.conf
  sed -i -e "831i project_domain_name = default" compute/config/neutron.conf
  sed -i -e "832i user_domain_name = default" compute/config/neutron.conf
  sed -i -e "833i project_name = service" compute/config/neutron.conf
  sed -i -e "834i username = neutron" compute/config/neutron.conf
  sed -i -e "834i password = ${NEUTRON_ADMINPASS}" compute/config/neutron.conf

  echo "[OSTACK] Get neutron configuration file.."
  cp compute/config/backup/linuxbridge_agent.ini.ori compute/config/linuxbridge_agent.ini

  echo "[OSTACK] Configuring linuxbridge_agent.."
  sed -i -e "157d" compute/config/linuxbridge_agent.ini
  sed -i -e "157i physical_interface_mappings = provider:IN_P_COMP" compute/config/linuxbridge_agent.ini # --> will reconfigure later
  sed -i -e "188d" compute/config/linuxbridge_agent.ini
  sed -i -e "188i firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver" compute/config/linuxbridge_agent.ini
  sed -i -e "193d" compute/config/linuxbridge_agent.ini
  sed -i -e "193i enable_security_group = true" compute/config/linuxbridge_agent.ini
  sed -i -e "208d" compute/config/linuxbridge_agent.ini
  sed -i -e "208i enable_vxlan = true" compute/config/linuxbridge_agent.ini
  sed -i -e "234d" compute/config/linuxbridge_agent.ini
  sed -i -e "234i local_ip = IP_M_COMP" compute/config/linuxbridge_agent.ini # --> will reconfigure later
  sed -i -e "258d" compute/config/linuxbridge_agent.ini
  sed -i -e "258i l2_population = true" compute/config/linuxbridge_agent.ini

  echo "[OSTACK] Neutron in compute done."
}

config_file() {
  echo "[OSTACK] Copy service and server config file to controller.."
  cp services controller
  cp servers controller

  echo "[OSTACK] Copy service and server config file to compute.."
  cp services compute
  cp servers compute

  echo "[OSTACK] All config file created."
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

restart_script() {
  echo "[OSTACK] Creating restart-glance.sh.."

  cat > controller/config/restart-glance.sh <<EOF
#!/bin/bash

sudo service glance-registry restart
sudo service glance-api restart
EOF

  echo "[OSTACK] Change restart-glance.sh permission.."
  chmod +x controller/config/restart-glance.sh

  echo "[OSTACK] Creating restart-nova.sh for controller.."
  cat > controller/config/restart-nova.sh <<EOF
#!/bin/bash

sudo service nova-api restart
sudo service nova-scheduler restart
sudo service nova-conductor restart
sudo service nova-novncproxy restart
EOF

  echo "[OSTACK] Change restart-nova.sh for controller permission.."
  chmod +x controller/config/restart-nova.sh

  echo "[OSTACK] Creating restart-nova.sh for compute.."
  cat > compute/config/restart-nova.sh <<EOF
#!/bin/bash

sudo service nova-compute restart
EOF

  echo "[OSTACK] Change restart-nova.sh for compute permission.."
  chmod +x compute/config/restart-nova.sh


  echo "[OSTACK] Creating restart-neutron.sh for controller.."
  cat > controller/config/restart-neutron.sh <<EOF
#!/bin/bash

sudo service nova-api restart
sudo service neutron-server restart
sudo service neutron-linuxbridge-agent restart
sudo service neutron-dhcp-agent restart
sudo service neutron-metadata-agent restart
sudo service neutron-l3-agent restart
EOF

  echo "[OSTACK] Change restart-neutron.sh for controller permission.."
  chmod +x controller/config/restart-neutron.sh


  echo "[OSTACK] Creating restart-neutron.sh for compute.."

  cat > compute/config/restart-neutron.sh <<EOF
#!/bin/bash

sudo service nova-compute restart
sudo service neutron-linuxbridge-agent restart
EOF

  echo "[OSTACK] Change restart-neutron.sh for compute permission.."
  chmod +x compute/config/restart-neutron.sh

  echo "[OSTACK] All restart-script created."
}


echo " "
echo "====================================================================================="
echo "Welcome to openstack configuration generator"
echo "====================================================================================="
echo "Please answer this question carefully! "
read -p "Controller Management Network Interface [eth0, enp3s0f0]: " IN_MAN_CTRL
read -p "Controller management IP address [192.168.1.1]: " IP_MAN_CTRL
read -p "Controller provider Network Interface [eth0, enp3s0f0]: " IN_PRO_CTRL
read -p "Controller provider IP address [10.122.1.1]: " IP_PRO_CTRL
hosts
chrony
db
memcached
etcd
keystone
glance
nova_ctrl
nova_comp
neutron_ctrl
neutron_comp
config_file
openrc
restart_script

echo "[OSTACK] Generating config done."
