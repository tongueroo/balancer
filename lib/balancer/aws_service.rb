require 'aws-sdk-elasticloadbalancingv2'

module Balancer
  module AwsService
    def elb
      @elb ||= Aws::ElasticLoadBalancingV2::Client.new
    end
  end
end
