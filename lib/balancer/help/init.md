Generates starter `.balancer/profiles/default.yml` file.

## Examples

    balancer init
    balancer init --vpc-id vpc-123
    balancer init --vpc-id vpc-123 --subnets subnet-123 subnet-456 --security-groups sg-123

* If no `--vpc-id` option is provided, the default vpc is set in the starter profile file.
* If no `--subnets` option is provided, the default subnets belonging to the vpc is set.
* If no `--security-groups` option is provided, no security groups are set.
