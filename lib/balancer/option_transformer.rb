require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'

module Balancer
  class OptionTransformer
    def to_cli(options)
      params = []
      options.each do |k,v|
        case v
        when Symbol, String, Integer
          params << key_to_cli_option(k) + ' ' + v.to_s
        when Array
          values = []
          v.each do |o|
            if o.is_a?(Hash)
              o.each do |x,y|
                values << "#{x.to_s.camelize}=#{y}"
              end
            else # assume string
              values << o
            end
          end

          list = v.first.is_a?(Hash) ? values.join(',') : values.join(' ')
          params << key_to_cli_option(k) + ' ' + list
        else
          raise "the roof"
        end
      end
      params.join(' ')
    end

    # resource_arns => --resource-arns
    def key_to_cli_option(key)
      '--' + key.to_s.gsub('_','-')
    end
  end
end
