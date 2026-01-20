# Consul Server role

This is a role to deploy a Consul server.
Designed for use in Digital Ocean, but can be used in any Linux environment.

## Requirements

None.

## Role Variables


## Dependencies

None.

## Example Playbook

```yaml
    - hosts: servers
      roles:
         - { role: hashi-at-home.ansible-role-consul-server }
```

## License

MIT

## Author Information


Bruce Becker.
