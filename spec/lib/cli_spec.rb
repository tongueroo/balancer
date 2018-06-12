require "spec_helper"

describe Balancer::CLI do
  before(:all) do
    @args = "--noop"
  end

  describe "balancer" do
    it "create" do
      out = execute("exe/balancer create my-elb #{@args}")
      expect(out).to include("Creating load balancer")
    end

    it "destroy" do
      out = execute("exe/balancer destroy my-elb #{@args}")
      expect(out).to include("Destroying ELB")
    end

    commands = {
      "crea" => "create",
      "create" => "name",
      "dest" =>  "destroy",
    }
    commands.each do |command, expected_word|
      it "completion #{command}" do
        out = execute("exe/balancer completion #{command}")
        expect(out).to include(expected_word) # only checking for one word for simplicity
      end
    end
  end
end
