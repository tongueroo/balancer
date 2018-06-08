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
    end

    def create_elb
      puts "Creating load balancer: #{@name}"

      params = param.create_load_balancer
      puts "params:"
      pp params

      puts "Equivalent aws cli command:"
      puts "  aws elbv2 create-load-balancer --name #{@name} --subnets #{params[:subnets].join(' ')} --security-groups #{params[:security_groups].join(' ')}".colorize(:light_green)

      resp = elb.create_load_balancer(params)
      elb = resp.load_balancers.first
      puts "Load balancer created: #{elb.load_balancer_arn}"
    end

    # aws elbv2 create-target-group --name my-targets --protocol HTTP --port 80 --vpc-id vpc-12345678
    def create_target_group
      puts "Creating target group"

      params = param.create_target_group
      puts "params:"
      pp params

      puts "Equivalent aws cli command:"
      puts "  aws elbv2 create-target-group --name #{params[:name]} --protocol #{params[:protocol]} --port #{params[:port]} --vpc-id #{params[:vpc_id]}".colorize(:light_green)

      resp = elb.create_target_group(params)
      target_group = resp.target_groups.first
      puts "Target group created: #{target_group.target_group_arn}"
    end

    def param
      Param.new(@options)
    end
    memoize :param
  end
end
