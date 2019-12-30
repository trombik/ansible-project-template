# frozen_string_literal: true

shared_examples "a host with all basic tools installed" do
  tools = [
    # XXX serverspec does not understand vim--no_x11
    { cmd: "vim", opts: "--version" },
    { name: "zsh", cmd: "zsh", opts: "--version" },
    { name: "sudo", cmd: "sudo", opts: "--version" },
    { cmd: "tmux", opts: "-c uname" }
  ]
  tools.each do |p|
    if p.key?(:name)
      describe package(p[:name]) do
        it { should be_installed }
      end
    end

    describe command("#{p[:cmd]} #{p[:opts]}") do
      its(:exit_status) { should eq 0 }
    end
  end
end
