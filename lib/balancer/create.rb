require 'yaml'

module Balancer
  class Create
    include AwsService
    extend Memoist

    def initialize(options)
      @options = options
      @name = options[:name]
    end

    # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html
    def run
      created = create_elb
      unless created
        puts "Load balancer #{@name} already exists"
        return
      end
      create_target_group
      create_listener
    end

    def create_elb
      puts "Creating load balancer with params:"
      params = param.create_load_balancer
      pretty_display(params)

      aws_cli_command("aws elbv2 create-load-balancer", params)
      return if @options[:noop]

      begin
        resp = elb.create_load_balancer(params)
      rescue Aws::ElasticLoadBalancingV2::Errors::DuplicateLoadBalancerName => e
        puts "#{e.class}: #{e.message}" if ENV['DEBUG']
        return false
      rescue Exception => e
        puts "ERROR: #{e.class}: #{e.message}".colorize(:red)
        exit 1
      end

      elb = resp.load_balancers.first
      puts "Load balancer created: #{elb.load_balancer_arn}"
      @load_balancer_arn = elb.load_balancer_arn # used later
      puts
      true
    end

    def create_target_group
      puts "Creating target group with params:"
      params = param.create_target_group
      pretty_display(params)

      aws_cli_command("aws elbv2 create-target-group", params)

      begin
        resp = elb.create_target_group(params)
      rescue Exception => e
        puts "ERROR: #{e.class}: #{e.message}".colorize(:red)
        exit 1
      end
      target_group = resp.target_groups.first
      puts "Target group created: #{target_group.target_group_arn}"
      @target_group_arn = target_group.target_group_arn # used later
      add_tags(@target_group_arn)
      puts
    end

    def create_listener
      puts "Creating listener with params:"
      params = param.create_listener
      params.merge!(
        load_balancer_arn: @load_balancer_arn,
        default_actions: [{type: "forward", target_group_arn: @target_group_arn}]
      )
      pretty_display(params)

      aws_cli_command("aws elbv2 create-listener", params)

      resp = run_with_error_handling do
        elb.create_listener(params)
      end
      listener = resp.listeners.first
      puts "Listener created: #{listener.listener_arn}"
      puts
    end

    def run_with_error_handling
      yield
    rescue Exception => e
      puts "ERROR: #{e.class}: #{e.message}".colorize(:red)
      exit 1
    end

    def add_tags(arn)
      params = {
        resource_arns: [arn],
        tags: [{ key: "balancer", value: @name }]
      }
      elb.add_tags(params)
      aws_cli_command("aws elbv2 add-tags", params)
    end

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
      puts "Equivalent aws cli command:"
      cli_options = option_transformer.to_cli(params)
      puts "  #{aws_command} #{cli_options}".colorize(:light_blue)
    end
  end
end
