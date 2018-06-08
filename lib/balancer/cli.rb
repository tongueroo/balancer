module Balancer
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "create NAME", "Create Load Balancer."
    long_desc Help.text(:create)
    # create_load_balancer options
    option :subnets, type: :array, desc: "Subnets"
    option :security_groups, type: :array, desc: "Security groups"
    # create_target_group options
    option :vpc_id, type: :array, desc: "Vpc id"
    option :target_group_name, desc: "Target group name"
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "destroy NAME", "Destroy Load Balancer and associated target group."
    long_desc Help.text(:destroy)
    def destroy(name)
      Destroy.new(options.merge(name: name)).run
    end

    desc "completion *PARAMS", "Prints words for auto-completion."
    long_desc Help.text("completion")
    def completion(*params)
      Completer.new(CLI, *params).run
    end

    desc "completion_script", "Generates a script that can be eval to setup auto-completion."
    long_desc Help.text("completion_script")
    def completion_script
      Completer::Script.generate
    end

    desc "version", "prints version"
    def version
      puts VERSION
    end
  end
end
