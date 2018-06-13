$:.unshift(File.expand_path("../", __FILE__))
require "balancer/version"
require "colorize"
require "memoist"

module Balancer
  autoload :AwsService, "balancer/aws_service"
  autoload :Help, "balancer/help"
  autoload :Setting, "balancer/setting"
  autoload :Base, "balancer/base"
  autoload :Profile, "balancer/profile"
  autoload :Init, "balancer/init"
  autoload :Core, "balancer/core"
  autoload :Command, "balancer/command"
  autoload :CLI, "balancer/cli"
  autoload :Create, "balancer/create"
  autoload :Completion, "balancer/completion"
  autoload :Completer, "balancer/completer"
  autoload :Destroy, "balancer/destroy"
  autoload :Param, "balancer/param"
  autoload :OptionTransformer, "balancer/option_transformer"
  autoload :SecurityGroup, "balancer/security_group"

  extend Core
end
