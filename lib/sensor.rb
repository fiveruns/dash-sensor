require 'fiveruns/dash'

module Dash
  module Sensor

    class Engine

      def start(options)
        load_plugins(options)
        wait_forever
      end

      private

      def load_plugins(options)
        # Add the user's config directory to the load path so they can load custom plugins
        # without modifying this gem.
        $PLUGIN_PATH = [
          File.dirname(options.config_file), 
          File.expand_path(File.join(File.dirname(__FILE__), '..', 'plugins')),
          nil
        ]

        setup = Setup.new
        config = File.read(options.config_file)
        setup.instance_eval(config, options.config_file)

        start_dash(setup)
      end

      def start_dash(setup)
        LOG.info("Starting Dash Sensor for #{setup.name} [#{setup.token}]")
        Fiveruns::Dash.configure :app => setup.token do |config|
          setup.plugins.each do |plugin|
            config.add_recipe plugin
          end
        end
        Fiveruns::Dash.session.reporter.interval = 60
        Fiveruns::Dash.session.start
      end

      def wait_forever
        while true
          sleep 60
        end
      end
    end

    class Setup
      
      attr_accessor :token, :name, :plugins

      def initialize
        self.plugins = []
        self.name = 'My App Name'
        self.token = 'change-me-to-your-app-token'
      end
      
      def plugin(name, options={})
        LOG.info("Loading plugin #{name} with options #{options.inspect}")
        
        self.plugins << name.to_sym
        $PLUGIN_PATH.each do |path|
          raise ArgumentError, "Unable to find #{name}.rb in plugin path: #{$PLUGIN_PATH[0..-2].inspect}" unless path
          file = File.join(path, name)
          if File.exist?("#{file}.rb")
            LOG.debug "Loading #{file}"
            require file
            break
          end
        end

        klass = Dash::Sensor::Plugins.const_get(camelize(name))
        klass.const_get('INSTANCE').configure(options)
      end

      def url=(value)
        ENV['DASH_UPDATE'] = value
      end

      def sensor
        self
      end

      private

      def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
        if first_letter_in_uppercase
          lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        else
          lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
        end
      end
      
    end

  end
end