module Balancer
  class Profile < Base
    include Balancer::Template

    def load
      return @profile_params if @profile_params

      check!

      file = profile_file(profile_name)
      @profile_params = load_profile(file)
    end

    def check!
      file = profile_file(profile_name)
      return if File.exist?(file)

      puts "Unable to find a #{file.colorize(:green)} profile file."
      puts "Please double check that it exists or that you specified the right profile.".colorize(:red)
      exit 1
    end

    def load_profile(file)
      return {} unless File.exist?(file)

      puts "Using profile: #{file}".colorize(:green)
      text = RenderMePretty.result(file, context: context)
      begin
        data = YAML.load(text)
      rescue Psych::SyntaxError => e
        tmp_file = file.sub(".balancer", "tmp")
        FileUtils.mkdir_p(File.dirname(tmp_file))
        IO.write(tmp_file, text)
        puts "There was an error evaluating in your yaml file #{file}".colorize(:red)
        puts "The evaludated yaml file has been saved at #{tmp_file} for debugging."
        puts "ERROR: #{e.message}"
        exit 1
      end
      data ? data : {} # in case the file is empty
      data.has_key?("create_load_balancer") ? data["create_load_balancer"] : data
    end

    # Determines a valid profile_name. Falls back to default
    def profile_name
      # allow user to specify the path also
      if @options[:profile] && File.exist?(@options[:profile])
        filename_profile = File.basename(@options[:profile], '.yml')
      end

      name = derandomize(@name)
      if File.exist?(profile_file(name))
        name_profile = name
      end

      filename_profile ||
      @options[:profile] ||
      name_profile || # conventional profile is the name of the elb
      "default"
    end

    def profile_file(name)
      "#{Balancer.root}/.balancer/#{name}.yml"
    end
  end
end
