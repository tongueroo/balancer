require 'pathname'
require 'yaml'

module Balancer
  module Core
    def root
      path = ENV['BALANCER_ROOT'] || '.'
      Pathname.new(path)
    end

    def profile
      ENV['BALANCER_PROFILE'] || 'default'
    end

    def settings
      Setting.new.data
    end

    def validate_in_project!
      unless File.exist?("#{root}/.balancer")
        puts "Could not find a .balancer folder in the current directory.  It does not look like you are running this command within a balancer project.  Please confirm that you are in a balancer project and try again.".colorize(:red)
        exit
      end
    end
  end
end
