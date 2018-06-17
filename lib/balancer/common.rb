module Balancer
  module Common
    extend Memoist

    def say(text=nil)
      logger.info(text)
    end

    def logger
      logger = Logger.new($stdout)
      logger.level = Kernel.const_get("Logger::#{Balancer.log_level.upcase}")
      # https://stackoverflow.com/questions/14382252/how-to-format-ruby-logger
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      logger
    end
    memoize :logger

    def security_group
      SecurityGroup.new(@options)
    end
    memoize :security_group

    def param
      Param.new(@options)
    end
    memoize :param

    def pretty_display(data)
      data = data.deep_stringify_keys
      say YAML.dump(data)
    end

    def option_transformer
      Balancer::OptionTransformer.new
    end
    memoize :option_transformer

    def aws_cli_command(aws_command, params)
      cli_options = option_transformer.to_cli(params)
      say "  #{aws_command} #{cli_options}".colorize(:light_blue)
    end
  end
end
