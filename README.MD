## The Execute order

On `controller`:
1. On `env`:
  + dep_env_controller
  + conf_env_controller
2. On `keystone`:
  + dep_keystone_controller
  + conf_keystone_db
  + conf_keystone_controller

On `compute`:
1. On `env`:
  + dep_env_compute
  + conf_env_compute
