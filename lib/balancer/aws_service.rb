require 'aws-sdk-ec2'
require 'aws-sdk-elasticloadbalancingv2'

module Balancer
  module AwsService
    def elb
      @elb ||= Aws::ElasticLoadBalancingV2::Client.new
    end

    def ec2
      @ec2 ||= Aws::EC2::Client.new
    end
  end
end
