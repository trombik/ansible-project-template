# ansible-role-hostname

Configure `hostname(1)`

## Notes for Ubuntu users

Ubuntu does not manage DNS domain name of the host. It is up to the users to
set up one. Note that it is officially stated that setting `/etc/hostname`,
which the role modifies, to FQDN is not the Right Thing. The role sets the
short form of `hostname_fqdn` in `/etc/hostname`, and silently discards the
rest of `hostname_fqdn`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `hostname_fqdn` | string of FQDN | `""` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - trombik.hosts
    - ansible-role-hostname
  vars:
    fqdn: fqdn.example.org
    fqdn_short: "{{ fqdn.split('.') | first }}"
    hostname_fqdn: "{{ fqdn }}"
    hosts_extra_localhosts:
      - "{{ fqdn }}"
      - "{{ fqdn_short }}"
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
