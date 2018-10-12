## Network interface configuration

Before deploy all the scripts make sure you've configure the network interface `/etc/network/interface` like this:

    auto lo
    iface lo inet loopback

    auto enp3s0f0
    iface enp3s0f0 inet static
          address 192.168.100.2
          netmask 255.255.255.0
          gateway 192.168.100.1
          dns-nameserver 202.46.129.3 202.46.129.2

    auto enp3s0f1
    iface enp3s0f1 inet manual
          up ip link set dev $IFACE up
          down ip link set dev $IFACE down

In case the IP address of **controller** or **compute** is `192.168.100.2` and the **management interface** is `enp3s0f0` and the **controller interface** is `enp3s0f1`.

### In case with Ubuntu 18.04.1 LTS

There are some major upgrade like the interface configuration is using `netplan`. Here i suggest you to use `net-tools` instead of `netplan`, like the previous LTS version (Ubuntu 16.04).

Install net-tools:

    $ sudo apt install net-tools ifupdown

Find and change grub configuration in `/etc/default/grub` to disable netplan:

    GRUB_CMDLINE_LINUX="netcfg/do_not_use_netplan=true"

## Main Program

+ `services` contain info about the services, **edit** it before generate config with `generate-config.sh`.
+ `servers` contain all info about the server and **don't edit** this. It will automatically fill when execute `generate-config.sh`.
+ `generate-config.sh` to generate all configuration before send to the server.
+ `send2server.sh` are use to send to the server as controller or compute to deploy later.
+ `clean.sh` to clean configuration after generate it.

## Optional Program

+ `pull-controller` get configuration from controller. **[WARNING! READ and EDIT it before use]**.
+ `pull-compute` get configuration from compute. **[WARNING! READ and EDIT it before use]**.
+ `vbox-testing` a directory which contain script to force interface configuration when use virtualbox to run openstack. **[WARNING! READ and EDIT it before use]**.

## Execute Order

Here the execute order to deploy openstack with this program, make sure you follow all this step and read every instruction and post installation notes when execute it.

+ Edit `servers` configuration file.
+ Execute `generate-config.sh` and follow all instruction and requirement.

        $ ./generate-config.sh

+ Execute `send2server.sh` and follow all instruction and requirement.

        $ ./send2server.sh

+ After all configuration send to controller and compute, just execute it by the number on script name (ex. `1_conf_host.sh`, `2_conf_env.sh`, `3_conf_keystone.sh` and etc) in the controller and all compute. Configure the controller first, follow all instruction and read post installation notes.

+ If all configure process are done. Just try to [Launch Instance](https://docs.openstack.org/install-guide/launch-instance.html) manually.

## Important Command to Check the Services are Running

Check keystone is running or not by check the provided token:

    $ openstack token issue

Check keystone is running or not by check the provided user, service and endpoint:

    $ openstack user list

    $ openstack service list

    $ openstack endpoint list

Check glance is running or not by check the provided OS images:

    $ openstack image list

Check nova is running or not by check all nova services:

    $ openstack compute service list

Check nova is running or not by check all services catalog:

    $ openstack catalog list

Check all nova service status (run as root):

    # nova-status upgrade check

Check neutron is running or not by check all the agent:

    $ openstack network agent list
