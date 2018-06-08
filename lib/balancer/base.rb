module Balancer
  class Base
    def initialize(options={})
      @options = options.clone
      @name = randomize(@options[:name])
      Balancer.validate_in_project!
    end

    # Appends a short random string at the end of the ec2 instance name.
    # Later we will strip this same random string from the name.
    # Very makes it convenient.  We can just type:
    #
    #   balancer create server --randomize
    #
    # instead of:
    #
    #   balancer create server-123 --profile server
    #
    def randomize(name)
      if @options[:randomize]
        random = (0...3).map { (65 + rand(26)).chr }.join.downcase # Ex: jhx
        [name, random].join('-')
      else
        name
      end
    end

    # Strip the random string at end of the ec2 instance name
    def derandomize(name)
      if @options[:randomize]
        name.sub(/-(\w{3})$/,'') # strip the random part at the end
      else
        name
      end
    end
  end
end
