## Sync Server IP Address

Modify the `servers` and `conf_hosts` script. The `conf_hosts` was located on `controller\env` and `compute\env`. Make sure the IP address, ethernet card, and server number are correct. The default configuration is:

+ Start on `server 0` as `controller`.
+ On `server 1` - `server-n` as `compute1` - `compute-n`, you can expand it.
+ Default ethernet card variable is `IP_ADDR0_ETH0` and `IP_ADDR0_ETH1`.
+ On `compute1` use `IP_ADDR1_ETH0` and `IP_ADDR1_ETH1`, so `IP_ADDR-n_ETH0` and `IP_ADDR-n_ETH1` for `compute-n`.

#### On `controller`

1. On `env`:
    + conf_hosts
    + dep_env_ctrl
    + conf_env_ctrl

#### On `compute`

1. On `env`:
    + conf_host
    + dep_env_comp
    + conf_env_comp

## Execute Order

Execute everything on `controller` before `compute`, like the execute order bellow. Make sure the IP address and the nodes were sycroinzed each other.

#### On `controller`

1. On `keystone`:
    + conf_keystone_db
    + dep_keystone_ctrl
    + conf_keystone_ctrl
2. On `glance`:
    + conf_glance_db
    + rel_glance_keystone
    + dep_glace_ctrl
    + conf_glace_ctrl
