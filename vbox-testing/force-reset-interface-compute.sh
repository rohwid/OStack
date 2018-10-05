#!/bin/bash


sudo cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
        address 192.168.100.11
        netmask 255.255.255.0
        gateway 192.168.100.1
        dns-nameservers 192.168.100.1

auto enp0s8
iface enp0s8 inet dhcp
EOF

sudo ifdown enp0s3 && sudo ifup enp0s3
sudo ifdown enp0s8 && sudo ifup enp0s8

sudo ifdown enp0s3 && sudo ifup enp0s3
sudo ifdown enp0s8 && sudo ifup enp0s8

ST_VAR='$IFACE'

sudo cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
        address 192.168.100.11
        netmask 255.255.255.0
        gateway 192.168.100.1
        dns-nameservers 192.168.100.1

auto enp0s8
iface enp0s8 inet manual
up ip link set dev $ST_VAR up
down ip link set dev $ST_VAR down
EOF

sudo ifdown enp0s3 && sudo ifup enp0s3
sudo ifdown enp0s8 && sudo ifup enp0s8

sudo ifdown enp0s3 && sudo ifup enp0s3
sudo ifdown enp0s8 && sudo ifup enp0s8

sudo ifdown enp0s3 && sudo ifup enp0s3
sudo ifdown enp0s8 && sudo ifup enp0s8
