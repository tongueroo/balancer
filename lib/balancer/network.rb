# Provides access to default network settings for a vpc: subnets and security_group
# If no @vpc_id is provided to the initializer then the default vpc is used.
module Balancer
  class Network
    include AwsService
    extend Memoist

    def initialize(vpc_id)
      @vpc_id = vpc_id
    end

    def vpc_id
      return @vpc_id if @vpc_id

      resp = ec2.describe_vpcs(filters: [
        {name: "isDefault", values: ["true"]}
      ])
      resp.vpcs.first.vpc_id
    end
    memoize :vpc_id

    def subnet_ids
      resp = ec2.describe_subnets(filters: [
        {name: "vpc-id", values: [vpc_id]}
      ])
      resp.subnets.map(&:subnet_id).sort
    end
    memoize :subnet_ids

    def security_group_id
      resp = ec2.describe_security_groups(filters: [
        {name: "vpc-id", values: [vpc_id]},
        {name: "group-name", values: ["default"]}
      ])
      resp.security_groups.first.group_id
    end
    memoize :security_group_id
  end
end
