# frozen_string_literal: true

require "English"
require "rspec/retry"
require "net/ssh"
require "pathname"
require "vagrant/serverspec"
require "vagrant/ssh/config"
$LOAD_PATH.unshift(Pathname.new(File.dirname(__FILE__)).parent + "ruby" + "lib")
require "ansible_inventory"

ENV["LANG"] = "C"

ENV["ANSIBLE_ENVIRONMENT"] = "virtualbox" unless ENV["ANSIBLE_ENVIRONMENT"]

# XXX OpenBSD needs TERM when installing packages
ENV["TERM"] = "xterm"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = "default"
  config.verbose_retry = true
  config.display_try_failure_messages = true
end

# Returns ANSIBLE_ENVIRONMENT
#
# @return [String] ANSIBLE_ENVIRONMENT if defined in ENV. defaults to "staging"
def test_environment
  ENV.key?("ANSIBLE_ENVIRONMENT") ? ENV["ANSIBLE_ENVIRONMENT"] : "virtualbox"
end

# Returns inventory object
#
# @return [AnsibleInventory]
def inventory
  AnsibleInventory.new(inventory_path)
end

# Returns path to inventory file
#
# @return [String]
def inventory_path
  Pathname.new(__FILE__)
          .parent
          .parent + "inventories" + test_environment
end
