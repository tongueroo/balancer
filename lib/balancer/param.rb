require 'active_support/core_ext/hash'

module Balancer
  class Param
    extend Memoist

    def initialize(options)
      @options = options
    end

    def create_load_balancer
      params = settings[:create_load_balancer]
      params = merge_option(params, :name)
      params = merge_option(params, :subnets)
      params = merge_option(params, :security_groups)
      params[:tags] = [{ key: "balancer", value: @options[:name] }]
      params
    end
    memoize :create_load_balancer

    def create_target_group
      params = settings[:create_target_group]
      params[:name] ||= @options[:name] if @options[:name] # settings take precedence
      params = merge_option(params, :vpc_id)
      params
    end
    memoize :create_target_group

    def modify_target_group_attributes
      attrs = settings[:modify_target_group_attributes]
      attrs[:attributes]
      attrs
    end
    memoize :modify_target_group_attributes

    def create_listener
      settings[:create_listener]
    end
    memoize :create_listener

    def merge_option(params, option_key)
      params[option_key] = @options[option_key] if @options[option_key]
      params
    end

    def settings
      @settings ||= Balancer.settings.deep_symbolize_keys
    end
  end
end
