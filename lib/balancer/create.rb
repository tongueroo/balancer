module Balancer
  class Create
    def initialize(options)
      @options = options
      @name = options[:name]
    end

    def run
      puts "Creating load balancer: #{@name}"
    end
  end
end
