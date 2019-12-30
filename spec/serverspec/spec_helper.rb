# frozen_string_literal: true

require "serverspec"
require "net/ssh/proxy/command"
require_relative "../spec_helper"
$LOAD_PATH.unshift(
  Pathname.new(File.dirname(__FILE__)).parent.parent + "ruby" + "lib"
)

Dir[File.dirname(__FILE__) + "/types/*.rb"].each { |f| require f }
Dir[File.dirname(__FILE__) + "/shared_examples/*.rb"].each { |f| require f }

host = ENV["TARGET_HOST"]

proxy = nil
options = {}

case test_environment
when "virtualbox"
  ssh_options = Vagrant::SSH::Config.for(host)
  proxy = if ssh_options.key?("ProxyCommand".downcase)
            Net::SSH::Proxy::Command.new(ssh_options["ProxyCommand".downcase])
          else
            false
          end

  options = {
    host_name: ssh_options["HostName".downcase],
    port: ssh_options["Port".downcase],
    user: ssh_options["User".downcase],
    keys: ssh_options["IdentityFile".downcase],
    keys_only: ssh_options["IdentitiesOnly".downcase],
    verify_host_key: ssh_options["StrictHostKeyChecking".downcase]
  }
when "staging"
  # proxy = Net::SSH::Proxy::Command.new(
  #   'ssh jumpguy@jump.server.enterprise.com nc %h %p'
  # )
  options = {
    host_name: inventory.host(host)["ansible_host"],
    port: 22,
    user: "ec2-user",
    keys_only: true,
    keys: ["/usr/home/trombik/.ssh/id_rsa-trombik"],
    verify_host_key: :never
  }
end
# host_name, port, user, keys, keys_only, verify_host_key
options[:proxy] = proxy if proxy

set :backend, :ssh
set :sudo_password, ENV["SUDO_PASSWORD"] if ENV.key?("SUDO_PASSWORD")

set :host, host
set :ssh_options, options
set :request_pty, true
set :env, LANG: "C", LC_MESSAGES: "C"
