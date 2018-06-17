module Balancer
  class Destroy
    extend Memoist
    include AwsService
    include Common

    def initialize(options)
      @options = options
      @name = options[:name]
    end

    def run
      destroy_load_balancer
      security_group.destroy
    end

    def destroy_load_balancer
      say "Destroying ELB '#{@name}' and associated resources."
      return if @options[:noop]

      begin
        resp = elb.describe_load_balancers(names: [@name])
      rescue Aws::ElasticLoadBalancingV2::Errors::LoadBalancerNotFound
        say "Load balancer '#{@name}' not found. Not destroying.".colorize(:red)
        return
      end

      load_balancer = resp.load_balancers.first

      # Must load resources to be deleted into memory to delete them later since there
      # are dependencies and they won't be available to query after deleting some of the
      # resources.
      resp = elb.describe_listeners(load_balancer_arn: load_balancer.load_balancer_arn)
      listeners = resp.listeners
      resp = elb.describe_target_groups(load_balancer_arn: load_balancer.load_balancer_arn)
      groups = resp.target_groups

      listeners.each do |listener|
        elb.delete_listener(listener_arn: listener.listener_arn)
        say "Deleted listener: #{listener.listener_arn}"
      end

      groups.each do |group|
        elb.delete_target_group(target_group_arn: group.target_group_arn)
        say "Deleted target group: #{group.target_group_arn}"
      end

      resp = elb.delete_load_balancer(
        load_balancer_arn: load_balancer.load_balancer_arn,
      )
      say "Deleted load balancer: #{load_balancer.load_balancer_arn}"
    end
  end
end
