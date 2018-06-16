module Balancer
  module SecurityGroup
    extend Memoist

    def security_group_name
      "#{@name}-elb"
    end

    def create_security_group
      sg = find_security_group(security_group_name)
      group_id = sg.group_id if sg

      unless group_id
        puts "Creating security group #{security_group_name} in vpc #{sg_vpc_id}"
        params = {group_name: security_group_name, description: security_group_name, vpc_id: sg_vpc_id}
        aws_cli_command("aws ec2 create-security-group", params)
        begin
          resp = ec2.create_security_group(params)
        rescue Aws::EC2::Errors::InvalidVpcIDNotFound => e
          puts "ERROR: #{e.class} #{e.message}".colorize(:red)
          exit 1
        end
        group_id = resp.group_id
        puts "Created security group: #{group_id}"
      end

      authorize_elb_port(group_id)

      ec2.create_tags(resources: [group_id], tags: [{
        key: "Name",
        value: security_group_name
      },
        key: "balancer",
        value: security_group_name
      ])

      group_id
    end

    # --sg-cidr option takes highest precedence
    def security_group_cidr
      @options[:sg_cidr] || param.settings[:security_group][:cidr]
    end

    def authorize_elb_port(group_id)
      resp = ec2.describe_security_groups(group_ids: [group_id])
      sg = resp.security_groups.first

      already_authorized = sg.ip_permissions.find do |perm|
        perm.from_port == 80 &&
        perm.to_port == 80
        perm.ip_ranges.find { |ip_range| ip_range.cidr_ip == security_group_cidr }
      end
      if already_authorized
        return
      end

      listener_port = param.create_listener[:port]

      # authorize the matching port in the create_listener setting
      params = {group_id: group_id, protocol: "tcp", port: listener_port, cidr: security_group_cidr}
      puts "Authorizing listening port for security group"
      aws_cli_command("aws ec2 authorize-security-group-ingress", params)
      ec2.authorize_security_group_ingress(
        group_id: params[:group_id],
        ip_permissions: [
          from_port: listener_port,
          to_port: listener_port,
          ip_protocol: "tcp",
          ip_ranges: [
            cidr_ip: security_group_cidr,
            description: "balancer #{security_group_name}"
          ]
        ]
      )
    end

    def destroy_security_group
      sg = find_security_group(security_group_name)
      return unless sg

      balancer_tag = sg.tags.find { |t| t.key == "balancer" && t.value == security_group_name }
      unless balancer_tag
        puts "WARN: not destroying the #{security_group_name} security group because it doesn't have a matching balancer tag".colorize(:yellow)
        return
      end

      puts "Deleting security group #{security_group_name} in vpc #{sg_vpc_id}"
      params = {group_id: sg.group_id}
      aws_cli_command("aws ec2 delete-security-group", params)

      retries = 0
      begin
        ec2.delete_security_group(params)
        puts "Deleted security group: #{sg.group_id}"
      rescue Aws::EC2::Errors::DependencyViolation => e
        if retries == 0
          puts "WARN: #{e.class} #{e.message}"
          puts "Unable to delete the security group because it's still in use by another resource. This might be the ELB which can take a little time to delete. Backing off expondentially and will try to delete again."
        end
        seconds = 2**retries
        puts "Retry: #{retries+1} Delay: #{seconds}s"
        sleep seconds
        retries += 1
        if retries <= 6
          # retry because it takes some time for the load balancer to be deleted
          # and that can cause a DependencyViolation exception
          retry
        else
          puts "WARN: #{e.class} #{e.message}".colorize(:yellow)
          puts "Unable to delete the security group because it's still in use by another resource. Leaving the security group."
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

    # Few other common methods also included here

    def param
      Param.new(@options)
    end
    memoize :param

    def pretty_display(data)
      data = data.deep_stringify_keys
      puts YAML.dump(data)
    end

    def option_transformer
      Balancer::OptionTransformer.new
    end
    memoize :option_transformer

    def aws_cli_command(aws_command, params)
      # puts "Equivalent aws cli command:"
      cli_options = option_transformer.to_cli(params)
      puts "  #{aws_command} #{cli_options}".colorize(:light_blue)
    end
  end
end
