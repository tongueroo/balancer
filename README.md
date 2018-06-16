# Balancer

[![Gem Version](https://badge.fury.io/rb/balancer.svg)](https://badge.fury.io/rb/balancer)
[![CircleCI](https://circleci.com/gh/tongueroo/balancer.svg?style=svg)](https://circleci.com/gh/tongueroo/balancer)[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=balancer)

Tool to create ELB load balancers with the appropriate target group, listener, and security group.

Usually, when creating ELBs, you also create a target group and listener and associate them to with ELB immediately afterward. This AWS Tutorial covers the steps: [Create an Application Load Balancer Using the AWS CLI
](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html)  The balancer tool automates the process with your custom pre-configured settings.

## Usage

Quick start to creating and destroying a load balancer.

    cd project
    balancer init --vpc-id vpc-123 --subnets subnet-123 subnet-456 --security-groups sg-123 # generates a default profile file
    # edit .balancer/profiles/default.yml to fit your needs
    balancer create my-elb
    balancer destroy my-elb

### Profiles

Balancer has a concept of profiles.  Profiles have preconfigured settings like subnets and vpc_id.  The params in the profiles are passed to the ruby [aws-sdk](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ElasticLoadBalancingV2/Client.html) api calls  `create_load_balancer`, `create_target_group`, and `create_listener`:

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
  port: 80 # required, this is is the port that gets open on the security group
```

### Security Groups

Balancer automatically creates a security group with the same name as the elb and opens up the port configured on the listener the profile file.  If you'll rather not using the automatically created security group set the security_groups in the profile file.

By default, the security group opens up `0.0.0.0/0`. If you want to override this use `--sg-cdir`, example:

    balancer create my-elb --sg-cdir 10.0.0.0/16

When you destroy the ELB like so:

    balancer destroy my-elb

Balancer also will destroy the security group if:

* The security group is tagged with the `balancer=my-elb` tag. Balancer automatically adds this tag to the security group when creating the ELB.
* There are no resources dependent on the security group. If there are dependencies the ELB is deleted but the security group is left behind for you to clean up.

## Installation

    gem install balancer

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
