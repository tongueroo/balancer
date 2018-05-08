require "spec_helper"

describe Balancer::CLI do
  before(:all) do
    @args = "--from Tung"
  end

  describe "balancer" do
    it "hello" do
      out = execute("exe/balancer hello world #{@args}")
      expect(out).to include("from: Tung\nHello world")
    end

    it "goodbye" do
      out = execute("exe/balancer sub goodbye world #{@args}")
      expect(out).to include("from: Tung\nGoodbye world")
    end

    commands = {
      "hell" => "hello",
      "hello" => "name",
      "hello -" =>  "--from",
      "hello name" => "--from",
      "hello name --" => "--from",
      "sub goodb" => "goodbye",
      "sub goodbye" => "name",
      "sub goodbye name" => "--from",
      "sub goodbye name --" => "--from",
      "sub goodbye name --from" => "--help",
    }
    commands.each do |command, expected_word|
      it "completion #{command}" do
        out = execute("exe/balancer completion #{command}")
        expect(out).to include(expected_word) # only checking for one word for simplicity
      end
    end
  end
end
