## Execute order

### On `controller`
1. On `env`:
    + dep_env_ctrl
    + conf_env_ctrl
2. On `keystone`:
    + conf_keystone_db
    + dep_keystone_ctrl
    + conf_keystone_ctrl
3. On `glance`:
    + conf_glance_db
    + rel_glance_keystone
    + dep_glace_ctrl
    + conf_glace_ctrl


### On `compute`
1. On `env`:
    + dep_env_comp
    + conf_env_comp
