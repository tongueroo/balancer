describe Balancer::OptionTransformer do
  let(:create) { Balancer::OptionTransformer.new }

  context '#to_cli' do
    it "target group" do
      options = {
        port: 80,
        protocol: "HTTP",
        load_balancer_arn: "load_balancer_arn",
        default_actions: [{type: "forward", target_group_arn: "target_group_arn"}],
      }
      text = create.to_cli(options)
      # puts text
      expect(text).to eq "--port 80 --protocol HTTP --load-balancer-arn load_balancer_arn --default-actions Type=forward,TargetGroupArn=target_group_arn"
    end

    it "tags" do
      options = {
        resource_arns: %w[arn1 arn2],
        tags: [{ key: "balancer", value: "test-elb" }]
      }
      text = create.to_cli(options)
      # puts text
      expect(text).to eq "--resource-arns arn1 arn2 --tags Key=balancer,Value=test-elb"
    end
  end
end
