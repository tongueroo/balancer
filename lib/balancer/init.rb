require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'
require 'bundler'

module Balancer
  class Init < Thor::Group
    include Thor::Actions

    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with cli-template new help :(
    # If anyone knows how to fix this let me know.
    # Also options from the cli can be pass through to here
    def self.cli_options
      [
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:git, type: :boolean, default: true, desc: "Git initialize the project"],
        [:subnets, type: :array, default: ["REPLACE_ME"], desc: "Subnets"],
        [:security_groups, type: :array, default: ["REPLACE_ME"], desc: "Security groups"],
        [:vpc_id, default: "REPLACE_ME", desc: "Vpc id"],
      ]
    end

    cli_options.each do |args|
      class_option *args
    end

    def self.source_root
      File.expand_path("../template", File.dirname(__FILE__))
    end

    def init_project
      puts "Setting up balancer files."
      directory ".", "."
    end

    def user_message
      puts <<-EOL
#{"="*64}
Congrats 🎉 Balancer starter files succesfully created.

Check out .balancer/profiles/default.yml make make sure the settings like subnets and vpc_id are okay.  Then run `balanace create` to to create an ELB, Target Group and listener. Example:

    balancer create my-elb
EOL
    end
  end
end
