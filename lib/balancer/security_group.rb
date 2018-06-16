module Balancer
  class SecurityGroup
    extend Memoist
    include AwsService
    include Common

    def initialize(options)
      @options = options
    end

    def security_group_name
      "#{@options[:name]}-elb"
    end

    def say(text)
      puts text unless @options[:mute]
    end

    def create
      group_id = create_security_group(security_group_name)
      port = param.create_listener[:port]
      # --sg-cidr option takes highest precedence
      ip_range = @options[:sg_cidr] || param.settings[:security_group][:cidr]
      authorize_port(
        group_id: group_id,
        from_port: port,
        to_port: port,
        ip_range: ip_range)

      ec2.create_tags(resources: [group_id], tags: [{
        key: "Name",
        value: security_group_name
      },
        key: "balancer",
        value: security_group_name
      ])

      group_id
    end

    def create_security_group(security_group_name)
      sg = find_security_group(security_group_name)
      group_id = sg.group_id if sg

      unless group_id
        say "Creating security group #{security_group_name} in vpc #{sg_vpc_id}"
        params = {group_name: security_group_name, description: security_group_name, vpc_id: sg_vpc_id}
        aws_cli_command("aws ec2 create-security-group", params)
        begin
          resp = ec2.create_security_group(params)
        rescue Aws::EC2::Errors::InvalidVpcIDNotFound => e
          say "ERROR: #{e.class} #{e.message}".colorize(:red)
          exit 1
        end
        group_id = resp.group_id
        say "Created security group: #{group_id}"
      end
      group_id
    end

    def authorize_port(group_id:, from_port:, to_port:, ip_range:nil, groups:nil, description:nil)
      resp = ec2.describe_security_groups(group_ids: [group_id])
      sg = resp.security_groups.first

      # authorize the matching port in the create_listener setting
      params = {
        group_id: group_id,
        protocol: "tcp",
        from_port: from_port,
        to_port: to_port,
      }
      say "Authorizing listening port for security group"
      aws_cli_command("aws ec2 authorize-security-group-ingress", params)

      permission = {
        from_port: from_port,
        to_port: to_port,
        ip_protocol: "tcp"
      }
      if ip_range
        permission[:ip_ranges] = [
          cidr_ip: ip_range,
          description: "balancer #{security_group_name}"
        ]
      else
        permission[:user_id_group_pairs] = [
          {
            description: "ufo elb access",
            group_id: groups,
            # group_name: "String",
            # peering_status: "String",
            # user_id: "String",
            # vpc_id: "String",
            # vpc_peering_connection_id: "String",
          }
        ]
      end

      final_params = {
        group_id: params[:group_id],
        ip_permissions: [permission]
      }
      begin
        ec2.authorize_security_group_ingress(final_params)
      rescue Aws::EC2::Errors::InvalidPermissionDuplicate
        # silently fail
      end
    end

    def destroy
      sg = find_security_group(security_group_name)
      return unless sg

      balancer_tag = sg.tags.find do |t|
        t.key == "balancer" && t.value == security_group_name ||
        t.key == "ufo" && t.value == security_group_name
      end
      unless balancer_tag
        say "WARN: not destroying the #{security_group_name} security group because it doesn't have a matching balancer tag".colorize(:yellow)
        return
      end

      say "Deleting security group #{security_group_name} in vpc #{sg_vpc_id}"
      params = {group_id: sg.group_id}
      aws_cli_command("aws ec2 delete-security-group", params)

      retries = 0
      begin
        ec2.delete_security_group(params)
        say "Deleted security group: #{sg.group_id}"
      rescue Aws::EC2::Errors::DependencyViolation => e
        if retries == 0
          say "WARN: #{e.class} #{e.message}"
          say "Unable to delete the security group because it's still in use by another resource. This might be the ELB which can take a little time to delete. Backing off expondentially and will try to delete again."
        end
        seconds = 2**retries
        say "Retry: #{retries+1} Delay: #{seconds}s"
        sleep seconds
        retries += 1
        if retries <= 5
          # retry because it takes some time for the load balancer to be deleted
          # and that can cause a DependencyViolation exception
          retry
        else
          say "WARN: #{e.class} #{e.message}".colorize(:yellow)
          say "Unable to delete the security group because it's still in use by another resource. Leaving the security group: #{sg.group_id}"
          end
      end
    end

    # Use security group that is set in the profile under create_target_group
    def sg_vpc_id
      param.create_target_group[:vpc_id]
    end
    memoize :sg_vpc_id

    def find_security_group(name)
      resp = ec2.describe_security_groups(filters: [
        {name: "group-name", values: [name]},
        {name: "vpc-id", values: [sg_vpc_id]},
      ])
      resp.security_groups.first
    end
    memoize :find_security_group
  end
end
