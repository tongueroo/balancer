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
      create_elb
      create_target_group
      create_listener
    end

    def create_elb
      puts "Creating load balancer with params:"
      params = param.create_load_balancer
      pretty_display(params)

      puts "Equivalent aws cli command:"
      puts "  aws elbv2 create-load-balancer --name #{@name} --subnets #{params[:subnets].join(' ')} --security-groups #{params[:security_groups].join(' ')}".colorize(:light_green)

      resp = elb.create_load_balancer(params)
      elb = resp.load_balancers.first
      puts "Load balancer created: #{elb.load_balancer_arn}"
      @load_balancer_arn = elb.load_balancer_arn # used later
      puts
    end

    def create_target_group
      puts "Creating target group with params:"
      params = param.create_target_group
      pretty_display(params)

      puts "Equivalent aws cli command:"
      puts "  aws elbv2 create-target-group --name #{params[:name]} --protocol #{params[:protocol]} --port #{params[:port]} --vpc-id #{params[:vpc_id]}".colorize(:light_green)

      resp = elb.create_target_group(params)
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

      puts "Equivalent aws cli command:"
      puts "  aws elbv2 create-listener --load-balancer-arn #{params[:load_balancer_arn]} --protocol #{params[:protocol]} --port #{params[:port]} --default-actions Type=forward,TargetGroupArn=#{@target_group_arn}".colorize(:light_green)

      resp = elb.create_listener(params)
      listener = resp.listeners.first
      puts "Listener created: #{listener.listener_arn}"
      puts
    end

    def add_tags(arn)
      resources = [arn]
      elb.add_tags(
        resource_arns: resources,
        tags: [{ key: "balancer", value: "balancer" }]
      )
      puts "Equivalent aws cli command:"
      puts %Q|  aws elbv2 add-tags --resource-arns #{resources.join(' ')} --tags "Key=balancer,Value=balancer"|.colorize(:light_green)
    end

    def param
      Param.new(@options)
    end
    memoize :param

    def pretty_display(data)
      data = data.deep_stringify_keys
      puts YAML.dump(data)
    end
  end
end
