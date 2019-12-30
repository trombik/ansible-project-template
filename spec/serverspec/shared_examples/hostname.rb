# frozen_string_literal: true

shared_examples "a host with a valid hostname" do
  describe command("hostname") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    if os[:family] == "ubuntu"
      its(:stdout) { should match(/^#{ENV["TARGET_HOST"].split('.').first}$/) }
    else
      its(:stdout) { should match(/^#{ENV["TARGET_HOST"]}$/) }
    end
  end
end
