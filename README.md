# `ansible-project-template`

This is a template repository for automated deployment with `ansile`. The
template includes:

* A `virtualbox` environment for testing
* A `prod` environment for production
* `ansible` playbook to deploy basic tools, such as `vim`, `zsh`, etc
* A set of tests with `serverspec`
* A `Rakefile` that simplifies provision

## Requirements

### Requirements on Local machine

* Unix machine
* `ruby`
* `bundler`
* `ansible`
* `vagrant`
* `VirtualBox`

### Requirements on target machine

* One of FreeBSD, OpenBSD, Ubuntu, and CentOS
* Configured network interface
* Configured `sshd`
* A Unix account that can run `sudo(1)` as root
* `python`

## Environments

The project provides two environments. One for development and tests, and
another for production system.

`virtualbox` environment is used for development, where `virtualbox` VM is
launched and provisioned.

`prod` is for production system. It can be VMs on cloud service, or a physical
machine.

### Inventory

TBW

## Usage

Clone the repository.

```
git clone https://github.com/trombik/ansible-project-openhab
cd ansible-project-openhab
```

Setup `bundler`.

```
bundle install --path=~/.vendor/bundle
```

Replace `~/.vendor/bundle` with your directory to install gems.

The project is managed by a `Rakefile`. It provides targets to launch virtual
machines, provision them, and test the configured system.

Launch the VM.

```
bundle exec rake up
```

Provision the VM.

```
bundle exec rake provision
```

Test the system.

```
bundle exec rake test:serverspec:all
```

Login to the system (only for `virtualbox` environment).

```
vagrant ssh hab.i.trombik.org
```

Destroy the VM.

```
bundle exec rake clean
```

### Environment variables

#### HTTP proxy

The `Rakefile` supports proxy on local machine. It assumes that the proxy is
running on local machine, listening on port 8080. If it detects the port is
open, then, automatically set necessary proxy setting during the deployment,
which makes the process faster. Any HTTP proxy application works. Here I use
`polipo`.

```
polipo logFile= daemonise=false diskCacheRoot=~/tmp/cache allowedClients='0.0.0.0/0' proxyAddress='0.0.0.0' logSyslog=false logLevel=0xff proxyPort=8080 relaxTransparency=true
```

If you use other application on that port, `VAGRANT_HTTP_PROXY_PORT`
environment variable can be defined to override port 8080. Replace
`~/tmp/cache` with your cache directory.

#### Switching environment

`ANSIBLE_ENVIRONMENT` is an environment variable to switch the target
environment. If not defined, `virtualbox`, where you develop the system, is
assumed. Another environment is `prod`, which is the live production system.

To deploy to `prod`, run:

```
ANSIBLE_ENVIRONMENT=prod bundle exec rake provision
```

#### User to deploy

By default, user `vagrant` for `virtualbox` environment, and the Unix account
on the local machine, is used as `ssh` account. To override it, use
`ANSIBLE_USER` environment variable.

#### `ansible-vault`

To decrypt password protected files by `ansible-vault`, the `Rakefile` use
`ANSIBLE_VAULT_PASSWORD_FILE` environment variable. It should be path to
`ansible-vault` password file on local machine.

#### User to run specs

To test the system in `prod` environment, `SUDO_PASSWORD` environment variable
must be set, which is used to run specs on the target machine. Your local Unix
account (or `ANSIBLE_USER` account) must be able to run `sudo(1)` on the
target machine.
