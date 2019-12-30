require "spec_helper"
require "serverspec"

package = "sudo"
config_dir = case os[:family]
             when "freebsd"
               "/usr/local/etc"
             else
               "/etc"
             end
confd_dir = "#{config_dir}/sudoers.d"
config = "#{config_dir}/sudoers"
flagments = %w[vagrant buildbot]
default_group = case os[:family]
                when "freebsd", "openbsd"
                  "wheel"
                else
                  "root"
                end
default_user = "root"

describe package(package) do
  it { should be_installed }
end

describe file confd_dir do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match(/# Managed by ansible$/) }
  its(:content) { should match(/^root ALL=\(ALL\) ALL$/) }
  its(:content) { should match(/^#includedir #{confd_dir}$/) }
end

flagments.each do |f|
  describe file "#{confd_dir}/#{f}" do
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 440 }
    its(:content) { should match(/# Managed by ansible$/) }
    its(:content) { should match(/^# #{f}$/) }
    its(:content) { should match(/^#{f}\s+ALL/) }
  end
end

describe file "#{confd_dir}/foo" do
  it { should_not exist }
end

describe command "sudo --version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/Sudo version/) }
end
