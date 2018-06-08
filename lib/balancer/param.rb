module Balancer
  class Param
    extend Memoist

    def initialize(options)
      @options = options
    end

    def create_load_balancer
      params = settings["create_load_balancer"].deep_symbolize_keys
      params = merge_option(params, :name)
      params = merge_option(params, :subnets)
      params = merge_option(params, :security_groups)
      params[:tags] = [{ key: "balancer", value: "balancer" }]
      params
    end
    memoize :create_load_balancer

    def create_target_group
      params = settings["create_target_group"].deep_symbolize_keys
      params[:name] ||= @options[:name] if @options[:name] # settings take precedence
      params = merge_option(params, :vpc_id)
      params
    end
    memoize :create_target_group

    def create_listener
      settings["create_listener"].deep_symbolize_keys
    end
    memoize :create_listener

    def merge_option(params, option_key)
      params[option_key] = @options[option_key] if @options[option_key]
      params
    end

    def settings
      @settings ||= Balancer.settings
    end
  end
end
