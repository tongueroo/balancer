require 'yaml'

module Balancer
  class Create
    extend Memoist
    include AwsService
    include Common

    attr_reader :target_group_arn
    def initialize(options)
      @options = options
      @name = options[:name]
    end

    # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html
    def run
      if ENV['TEST'] # ghetto way to for sanity cli specs
        say "Creating load balancer"
        return
      end

      load_balancer_arn = existing_target_group_arn
      if load_balancer_arn
        say "Load balancer #{@name} already exists: #{load_balancer_arn}"
        # ensure that target_group_arn is set for ufo
        @target_group_arn = find_target_group.target_group_arn
      end

      @security_group_id = security_group.create
      create_elb
      create_target_group
      modify_target_group_attributes
      create_listener
    end

    def existing_target_group_arn
      begin
        resp = elb.describe_load_balancers(names: [@name])
        resp.load_balancers.first.load_balancer_arn
      rescue Aws::ElasticLoadBalancingV2::Errors::LoadBalancerNotFound
        false
      end
    end

    # looks for existing target group arn associate with load balancer created
    # by ufo
    def find_target_group
      resp = elb.describe_target_groups(names: [@name])
      # assume first target group is one we want
      # TODO: add logic to look for target group with ufo tag
      # and then fall back to the first target group
      resp.target_groups.first
    end
    memoize :find_target_group

    def create_elb
      say "Creating load balancer with params:"
      params = param.create_load_balancer
      params[:security_groups] ||= []
      params[:security_groups] += [@security_group_id]
      params[:security_groups] = params[:security_groups].uniq
      pretty_display(params)
      aws_cli_command("aws elbv2 create-load-balancer", params)
      return if @options[:noop]

      begin
        resp = elb.create_load_balancer(params)
      rescue Exception => e
        puts "ERROR: #{e.class}: #{e.message}".colorize(:red)
        exit 1
      end

      elb = resp.load_balancers.first
      say "Load balancer created: #{elb.load_balancer_arn}"
      @load_balancer_arn = elb.load_balancer_arn # used later
      say
    end

    def create_target_group
      say "Creating target group with params:"
      params = param.create_target_group
      # override the target group name, takes higher precedence of profile file
      params[:name] = @options[:target_group_name] if @options[:target_group_name]
      pretty_display(params)
      aws_cli_command("aws elbv2 create-target-group", params)

      begin
        resp = elb.create_target_group(params)
      rescue Exception => e
        puts "ERROR: #{e.class}: #{e.message}".colorize(:red)
        exit 1
      end
      target_group = resp.target_groups.first
      say "Target group created: #{target_group.target_group_arn}"
      @target_group_arn = target_group.target_group_arn # used later
      add_tags(@target_group_arn)
      say
    end

    def modify_target_group_attributes
      params = param.modify_target_group_attributes
      params[:target_group_arn] = @target_group_arn
      pretty_display(params)
      aws_cli_command("aws elbv2 modify-target-group-attributes", params)
      elb.modify_target_group_attributes(params)
      say
    end

    def create_listener
      say "Creating listener with params:"
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
      say "Listener created: #{listener.listener_arn}"
      say
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
      aws_cli_command("aws elbv2 add-tags", params)
      elb.add_tags(params)
    end
  end
end
