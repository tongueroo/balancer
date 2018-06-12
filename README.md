# Balancer

[![Gem Version](https://badge.fury.io/rb/balancer.svg)](https://badge.fury.io/rb/balancer)
[![CircleCI](https://circleci.com/gh/tongueroo/balancer.svg?style=svg)](https://circleci.com/gh/tongueroo/balancer)[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=balancer)

Tool to create ELB load balancers with a target group and listener.  It's performs similar steps to this AWS Tutorial: [Create an Application Load Balancer Using the AWS CLI
](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html)

## Usage

Quick start to creating a load balancer.

    cd project
    balancer init --vpc-id vpc-123 --subnets subnet-123 subnet-456 --security-groups sg-123
    # edit .balancer/profiles/default.yml to fit your needs
    balancer create my-elb

### Profiles

Balancer has a concept of profiles.  Profiles have preconfigured settings like subnets and vpc_id.  The params in the profiles are passed to the ruby [aws-sdk](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ElasticLoadBalancingV2/Client.html) api calls like `create_load_balancer`, `create_target_group`, and `create_listener`:

```yaml
---
create_load_balancer:
  subnets: # at least 2 subnets groups required
    - subnet-123
    - subnet-345
  security_groups: # optional thanks to the automatically created security group by balancer
    - sg-123 # additional security groups to use
create_target_group:
  # vpc_id is required
  vpc_id: vpc-123
  # name: ... # automatically named, matches the load balancer name. override here
  protocol: HTTP # required
  port: 80 # required
create_listener:
  protocol: HTTP # required
```

### Security Groups

Balancer automatically creates a security group by the same name as the elb and opens up the port configured on the listener.  To disable this behavior, use the `--no-security-group` optional.  If you use this option, you must specify you own security group in the profile file.

Note, this security group is left behind if you destroy load balancer with `balancer destroy`.

## Installation

    gem install balancer

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
