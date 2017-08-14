## Sync Server IP Address

Modify the `servers` and `conf_hosts` script. The `conf_hosts` script was located on `controller\env` and `compute\env`. Make sure the IP address, ethernet card, and server number are correct. The default configuration and aloso the rule is:

+ Start on `server0` as `controller`.
+ In `server1` - `server-n` described as `compute1` - `compute-n`, and you can expand it.
+ Default ethernet card variable is `IP_ADDR0_ETH0` and `IP_ADDR0_ETH1`.
+ In `compute1` use `IP_ADDR1_ETH0` and `IP_ADDR1_ETH1`, so `IP_ADDR-n_ETH0` and `IP_ADDR-n_ETH1` for `compute-n`.
+ Every server has two ethernet card by default.

## Send to Server and Suicide

Use `send2server` script to send all this scripts to server. It will used to deploy and configure the openstack. If you wanna delete all your script in the server, just execute `suicide` script in it.

## Execute Order

Execute everything on `controller` before `compute`, like the execute order bellow. Make sure the IP address and the nodes were sycroinzed each other.

#### On `controller`

1. On `env`:
    + conf_hosts_ctrl
    + dep_env_ctrl
    + conf_env_ctrl

2. On `keystone`:
    + conf_keystonedb_ctrl
    + dep_keystone_ctrl
    + conf_keystone_ctrl

3. On `glance`:
    + conf_glance_db
    + rel_glance_keystone
    + dep_glace_ctrl
    + conf_glace_ctrl

#### On `compute`

1. On `env`:
    + conf_hosts_comp
    + dep_env_comp
    + conf_env_comp
