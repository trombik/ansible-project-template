# frozen_string_literal: true

require "English"
require "yaml"
require "pathname"
require "socket"
require "uri"

# https://gist.github.com/fnichol/7551540
# @return [String] public IP address of workstation used for egress traffic
def local_ip
  @local_ip ||= begin
                  # turn off reverse DNS resolution temporarily
                  orig = Socket.do_not_reverse_lookup
                  Socket.do_not_reverse_lookup = true

                  # open UDP socket so that it never send anything over the network
                  UDPSocket.open do |s|
                    s.connect "8.8.8.8", 1 # any global IP address works here
                    s.addr.last
                  end
                ensure
                  Socket.do_not_reverse_lookup = orig
                end
end

# @return [Integer] default listening port
def local_port
  ENV.key?("VAGRANT_HTTP_PROXY_PORT") ? ENV["VAGRANT_HTTP_PROXY_PORT"] : 8080
end

# @return [String] the proxy URL
def http_proxy_url
  "http://#{local_ip}:#{local_port}"
end

# @return [TrueClass,FalseClass] whether or not the port is listening
def proxy_running?
  socket = TCPSocket.new(local_ip, local_port)
  true
rescue SocketError, Errno::ECONNREFUSED,
       Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
  false
rescue Errno::EPERM, Errno::ETIMEDOUT
  false
ensure
  socket&.close
end
# XXX proxy handling should be roled into a library and the lines above should
# be removed from the file

http_proxy = proxy_running? ? http_proxy_url : ""

environment = ENV["ANSIBLE_ENVIRONMENT"] || "virtualbox"

# XXX these are Pathname objects. The object behaves like String, but they are
# not identical. When passing the variables to other objects, or classes as a
# String, make sure to convert them to String with `to_s`.
project_root_directory = Pathname.new(__FILE__).dirname
project_config = project_root_directory + "project.yml"
project = YAML.load_file(project_config)
inventory_root_directory = project_root_directory + "inventories"
inventory_directory = inventory_root_directory + environment
inventory_file = inventory_directory + "#{environment}.yml"
inventory = YAML.load_file(inventory_file)
playbooks_directory = project_root_directory + "playbooks"
raise "`#{project_config}` does not have mandatory key `name`" unless project.key?("name")

# group_name = project["name"]

Vagrant.configure("2") do |config|
  config.ssh.shell = "/bin/sh"

  case environment
  when "virtualbox"
    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 1
    end
    config.vm.box_check_update = false
    default_box = "trombik/ansible-ubuntu-18.04-amd64"
    hostname_by_priority = inventory["all"]["hosts"].keys.sort do |a, b|
      inventory["all"]["hosts"][b]["vagrant_priority"] <=> inventory["all"]["hosts"][a]["vagrant_priority"]
    end
    hostname_by_priority.each do |hostname|
      config.vm.define hostname do |c|
        c.vm.network "private_network", ip: inventory["all"]["hosts"][hostname]["ansible_host"]
        c.vm.hostname = inventory["all"]["hosts"][hostname]["project_fqdn"]
        c.vm.box = inventory["all"]["hosts"][hostname].key?("vagrant_box") ? inventory["all"]["hosts"][hostname]["vagrant_box"] : default_box
        if inventory["all"]["hosts"][hostname].key?("vagrant_extra_disks")
          inventory["all"]["hosts"][hostname]["vagrant_extra_disks"].each_with_index do |disk, index|
            c.vm.provider "virtualbox" do |virtualbox|
              unless File.exist?(disk["name"])
                virtualbox.customize ["createhd", "--filename", disk["name"],
                                      "--size", disk["size"]]
              end
              virtualbox.customize ["storageattach", :id,
                                    "--storagectl", "SCSI Controller",
                                    "--port", index + 1,
                                    "--device", 0,
                                    "--type", "hdd",
                                    "--medium", disk["name"]]
            end
          end
        end
        if inventory["all"]["hosts"][hostname].key?("vagrant_extra_networks")
          inventory["all"]["hosts"][hostname]["vagrant_extra_networks"].each do |n|
            raise "#{hostname} does not have ipv4 as a key under vagrant_extra_networks" unless n.key?("ipv4")

            c.vm.network "private_network", ip: n["ipv4"] if n.key?("ipv4")
          end
        end

        c.vm.provision :ansible do |ansible|
          python_path = case c.vm.box
                        when /openbsd/
                          "/usr/local/bin/python3"
                        when /freebsd/
                          "/usr/local/bin/python"
                        else
                          "/usr/bin/python"
                        end
          ansible_extra_vars_staging = {
            ansible_python_interpreter: python_path,
            ansible_user: "vagrant",
            ansible_ssh_private_key_file: Pathname.new("~/.vagrant.d/insecure_private_key").expand_path.to_s,
            http_proxy: http_proxy,
            https_proxy: http_proxy,
            no_proxy: format("localhost,127.0.0.1,trombik.org")
          }
          ansible.playbook = (playbooks_directory + "site.yml").to_s
          ansible.verbose = "v"
          ansible.inventory_path = inventory_directory.to_s
          ansible.extra_vars = ansible_extra_vars_staging
        end
      end
    end
  else
    raise "unknown environment: `#{environment}`"
  end
end
# vim: ft=ruby
