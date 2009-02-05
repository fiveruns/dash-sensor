require 'fiveruns/dash'
require 'sensor_plugin'

module Dash
  module Sensor

    RECIPES = []

    class Engine

      def self.registered(name, url, klass)
        klass.instance = klass.new
        RECIPES << [name, url, klass]
      end

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
          RECIPES.each do |(name, url, _)|
            config.add_recipe name.to_sym, url
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
      
      attr_accessor :token, :name

      def initialize
        self.name = 'My App Name'
        self.token = 'change-me-to-your-app-token'
      end
      
      def plugin(name, options={})
        LOG.info("Loading plugin #{name} with options #{options.inspect}")
        
        $PLUGIN_PATH.each do |path|
          raise ArgumentError, "Unable to find #{name}.rb in plugin path: #{$PLUGIN_PATH[0..-2].inspect}" unless path
          file = File.join(path, name)
          if File.exist?("#{file}.rb")
            LOG.debug "Loading #{file}"
            require file
            break
          end
        end

        RECIPES.last.last.instance.configure(options)
      end

      def url=(value)
        ENV['DASH_UPDATE'] = value
      end

      def sensor
        self
      end

    end

  end
end