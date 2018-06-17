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

    # Only set the BALANCER_PROFILE if not set already at the CLI. CLI takes
    # highest precedence.
    def set_profile(value)
      path = "#{root}/.balancer/profiles/#{value}.yml"
      unless File.exist?(path)
        puts "The profile file #{path} does not exist.  Exiting.".colorize(:red)
        exit 1
      end
      ENV['BALANCER_PROFILE'] = value
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

    # https://ruby-doc.org/stdlib-2.1.0/libdoc/logger/rdoc/Logger.html
    #
    # UNKNOWN - An unknown message that should always be logged.
    # FATAL - An unhandleable error that results in a program crash.
    # ERROR - A handleable error condition.
    # WARN - A warning.
    # INFO - Generic (useful) information about system operation.
    # DEBUG - Low-level information for developers.
    @@log_level = :info
    def log_level ; @@log_level ; end

    # Balancer.log_level = :warn
    def log_level=(v)
      @@log_level = v
    end
  end
end
