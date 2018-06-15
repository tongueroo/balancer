require 'pathname'
require 'yaml'

module Balancer
  module Core
    extend Memoist

    # native support for ufo
    # So if in a project with ufo, and it has a .ufo/balancer folder
    # that will be picked up as the default root automatically
    def root
      default_path = if Dir.glob(".ufo/.balancer/profiles/*").empty?
                       '.'
                     else
                       '.ufo'
                     end
      path = ENV['BALANCER_ROOT'] || default_path
      Pathname.new(path)
    end
    memoize :root

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
