$:.unshift(File.expand_path("../", __FILE__))
require "balancer/version"

module Balancer
  autoload :Help, "balancer/help"
  autoload :Command, "balancer/command"
  autoload :CLI, "balancer/cli"
  autoload :Sub, "balancer/sub"
  autoload :Completion, "balancer/completion"
  autoload :Completer, "balancer/completer"
end
