require "spec_helper"

RSpec.describe AnsibleInventory do
  let(:yaml) { File.read("spec/yaml/inventory.yml") }
  let(:i) { AnsibleInventory.new("spec/yaml") }
  before(:each) do
    status = double("status")
    allow(status).to receive(:success?).and_return(true)
    allow(i).to receive(:run_command).with("ansible-inventory --inventory 'spec/yaml' --yaml --list").and_return([yaml, "", status])

    list_hosts_output_staging    = "  hosts (2):\n    mx1_trombik_org\n    other_trombik_org\n"
    list_hosts_output_staging_mx = "  hosts (1):\n    mx1_trombik_org\n"
    allow(i).to receive(:run_command)
      .with("ansible --inventory 'spec/yaml' --list-hosts 'staging'")
      .and_return([list_hosts_output_staging, "", status])
    allow(i).to receive(:run_command)
      .with("ansible --inventory 'spec/yaml' --list-hosts 'staging-mx'")
      .and_return([list_hosts_output_staging_mx, "", status])
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
    # TODO: test failure patterns
    it "returns two hostname" do
      expect(i.all_hosts_in("staging")).to include("mx1.trombik.org", "other.trombik.org")
    end

    it "returns one hostname of group staging-mx" do
      expect(i.all_hosts_in("staging-mx")).to include("mx1.trombik.org")
      expect(i.all_hosts_in("staging-mx")).not_to include("other.trombik.org")
    end
  end

  describe ".find_hidden_groups" do
    it "returns empty array when parent does not have `children` as a key" do
      parent = { "hosts" => "" }
      expect(i.find_hidden_groups(parent)).to eq []
    end

    it "returns empty array when parent is nil" do
      expect(i.find_hidden_groups(nil)).to eq []
    end

    it "returns empty array when parent is empty Hash" do
      expect(i.find_hidden_groups({})).to eq []
    end

    it "returns empty array when parent has `children` as a key but the value is not hash" do
      expect(i.find_hidden_groups("children" => "")).to eq []
    end

    it "finds hidden groups" do
      parent = {
        "children" => {
          "foo" => {
            "children" => {
              "bar" => {
                "hosts" => {
                  "buz" => {}
                }
              }
            }
          }
        }
      }
      expect(i.find_hidden_groups(parent)).to include("foo", "bar")
      expect(i.find_hidden_groups(parent)).not_to include("buz")
    end
  end

  describe ".all_groups" do
    it "returns an array" do
      expect(i.all_groups.class).to eq Array
    end
    it "returns expected groups" do
      expect(i.all_groups).to include(
        "ami_ffde5a99",
        "staging",
        "staging-mx",
        "mx1.trombik.org",
        "tag_project_mx",
        "i-0636878f9f146df24",
        "tag_Name_mx1_trombik_org"
      )
    end
  end

  describe ".find_host_by_ec2_hostname" do
    it "returns mx1.trombik.org host Hash" do
      expect(i.find_host_by_ec2_hostname("mx1.trombik.org")["ec2_tag_Name"]).to eq "mx1.trombik.org"
      expect(i.find_host_by_ec2_hostname("mx1.trombik.org")["ansible_host"]).to eq "52.197.90.13"
    end
  end
end
