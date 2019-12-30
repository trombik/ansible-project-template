# `trombik.sudo`

A brief description of the role goes here.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `sudo_package` | package name of `sudo` | `{{ __sudo_package }}` |
| `sudo_extra_packages` | list of extra packages to install | `[]` |
| `sudo_config_dir` | path to configuration directory | `{{ __sudo_config_dir }}` |
| `sudo_confd_dir` | path do `sudoers.d` directory | `{{ sudo_config_dir }}/sudoers.d` |
| `sudo_configs` | list of files under `sudoers.d` (see below) | `[]` |
| `sudo_sudoer` | content of `sudoers(5)` | `""` |

## `sudo_configs`

This list of dict describes files under `sudoers.d`.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `name` | name of the file | Yes |
| `content | the content of the file | No |
| `state` | either `present` or `absent`. if ommited, `present` is assumed | No |

## Debian

| Variable | Default |
|----------|---------|
| `__sudo_package` | `sudo` |
| `__sudo_config_dir` | `/etc` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__sudo_package` | `sudo` |
| `__sudo_config_dir` | `/usr/local/etc` |
| `__sudo_conf_dir` | `/usr/local/etc/sudo` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__sudo_package` | `sudo` |
| `__sudo_config_dir` | `/etc` |

## RedHat

| Variable | Default |
|----------|---------|
| `__sudo_package` | `sudo` |
| `__sudo_config_dir` | `/etc` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-sudo
  vars:
    sudo_sudoer: |
      root ALL=(ALL) ALL
      #includedir {{ sudo_confd_dir }}

    sudo_configs:
      - name: vagrant
        content: |
          Defaults:vagrant !requiretty
          vagrant ALL=(ALL) NOPASSWD: ALL
          root ALL=(ALL) NOPASSWD: ALL
      - name: buildbot
        content: |
          Cmnd_Alias POUDRIERE = /usr/local/bin/poudriere
          buildbot ALL = (root) NOPASSWD: POUDRIERE
      - name: foo
        state: absent
```

# License

```
Copyright (c) 2019 Tomoyuki Sakurai <y@trombik.org>

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
