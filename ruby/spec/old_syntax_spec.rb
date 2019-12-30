require "spec_helper"

RSpec.describe AnsibleInventory do
  let(:yaml) { File.read("spec/yaml/virtualbox.yml") }
  let(:i) { AnsibleInventory.new("spec/yaml") }
  before(:each) do
    status = double("status")
    allow(status).to receive(:success?).and_return(true)
    allow(i).to receive(:run_command)
      .with("ansible-inventory --inventory 'spec/yaml' --yaml --list")
      .and_return([yaml, "", status])

    list_hosts_output_mx = "  hosts (1):\n    mx1_trombik_org\n"
    allow(i).to receive(:run_command)
      .with("ansible --inventory 'spec/yaml' --list-hosts 'mx'")
      .and_return([list_hosts_output_mx, "", status])
  end

  describe "#new" do
    it "does not throw exception" do
      expect { i }.not_to raise_exception
    end
  end

  describe ".config" do
    it "returns loaded YAML as hash" do
      expect(i.config.class).to eq Hash
    end
  end

  describe ".all_hosts_in" do
    it "returns a single hostname" do
      expect(i.all_hosts_in("mx")).to eq ["mx1.trombik.org"]
    end
  end

  describe ".all_groups" do
    it "returns an array" do
      expect(i.all_groups.class).to eq Array
      groups = %w[
        mx
        virtualbox-mx
        virtualbox-credentials
        virtualbox
      ]
      expect(i.all_groups).to include(groups)
    end
  end
end
