# frozen_string_literal: true

require_relative "../spec_helper"
require "net/http"

context "after provision finishes" do
  it_behaves_like "a host with a valid hostname"
  it_behaves_like "a host with all basic tools installed"
end
