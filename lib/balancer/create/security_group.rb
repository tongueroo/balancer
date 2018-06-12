class Balancer::Create
  module SecurityGroup
    def create_security_group
      begin
        resp = ec2.describe_security_groups(group_names: [@name])
        sg = resp.security_groups.first
        group_id = sg.group_id
      rescue Aws::EC2::Errors::InvalidGroupNotFound
        group_id = nil
      end

      unless group_id
        params = {group_name: @name, description: @name}
        aws_cli_command("aws ec2 create-security-group", params)
        resp = ec2.create_security_group(params)
        group_id = resp.group_id
      end

      authorize_elb_port(group_id)

      ec2.create_tags(resources: [group_id], tags: [{
        key: "Name",
        value: @name
      },
        key: "balancer",
        value: @name
      ])

      group_id
    end

    def authorize_elb_port(group_id)
      resp = ec2.describe_security_groups(group_ids: [group_id])
      sg = resp.security_groups.first

      already_authorized = sg.ip_permissions.find do |perm|
        perm.from_port == 80 &&
        perm.to_port == 80
        perm.ip_ranges.find { |ip_range| ip_range.cidr_ip == @options[:sg_cidr] }
      end
      if already_authorized
        return
      end

      listener_port = param.create_listener[:port]

      # authorize the matching port in the create_listener setting
      params = {group_id: group_id, protocol: "tcp", port: listener_port, cidr: @options[:sg_cidr]}
      aws_cli_command("aws ec2 authorize-security-group-ingress", params)
      ec2.authorize_security_group_ingress(
        group_id: params[:group_id],
        ip_permissions: [
          from_port: listener_port,
          to_port: listener_port,
          ip_protocol: "tcp",
          ip_ranges: [
            cidr_ip: @options[:sg_cidr],
            description: "balancer #{@name}"
          ]
        ]
      )
    end
  end
end
