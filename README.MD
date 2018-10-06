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
