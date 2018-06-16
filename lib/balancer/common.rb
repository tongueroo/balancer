module Balancer
  module Common
    extend Memoist

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
      puts YAML.dump(data)
    end

    def option_transformer
      Balancer::OptionTransformer.new
    end
    memoize :option_transformer

    def aws_cli_command(aws_command, params)
      # puts "Equivalent aws cli command:"
      cli_options = option_transformer.to_cli(params)
      puts "  #{aws_command} #{cli_options}".colorize(:light_blue)
    end
  end
end
