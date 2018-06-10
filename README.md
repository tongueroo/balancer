# Balancer

[![Gem Version](https://badge.fury.io/rb/GEMNAME.png)](http://badge.fury.io/rb/GEMNAME)
[![CircleCI](https://circleci.com/gh/USER/REPO.svg?style=svg)](https://circleci.com/gh/USER/REPO)
[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=balancer)

Tool to create ELB load balancers with a target group and listener.

## Usage

Quick start to creating a load balancer.

	cd project
	balancer init --vpc-id vpc-123 --subnets subnet-123 subnet-456 --security-groups sg-123
	# edit .balancer/profiles/default.yml to your needs
	balancer create my-elb

### Profiles

Balancer has a the concept of profiles.  Profiles have some preconfigured settings like subnets and vpc_id that can be set so you do not have to type it over and over.  The profile files are the parameters that passed to the corresponding aws-sdk api calls.

```yaml
---
create_load_balancer:
  subnets: # required
    - subnet-123
    - subnet-345
  security_groups: # normally required, but optional thanks to the automatically created security group
    - sg-123 # additional security groups to automatically created one
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

One automatically created security group is associated load balancer.  You can add own additional security groups by configuring the security_groups parameter in the profile file.

## Installation

    gem install balancer

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
