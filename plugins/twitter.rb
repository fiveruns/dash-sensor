require 'open-uri'

begin
  require 'nokogiri'
rescue LoadError => le
  puts [
    "The Twitter plugin requires the nokogiri gem.  Install with:",
    "   sudo gem install nokogiri"
    ].join("\n")
  raise le
end

# Collect common Twitter metrics and send them to Dash.
# Proof that Sensor and Dash work with more than boring old technical metrics.
# They work with boring social networking metrics too.  :-)
module Dash::Sensor::Plugins
  class Twitter
    include SensorPlugin

    register :twitter, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.absolute :updates do
        data[:update_count]
      end
      recipe.absolute :following do
        data[:following_count]
      end
      recipe.absolute :followers do
        data[:follower_count]
      end
      recipe.counter :tweets do
        count = data[:update_count] - old_data[:update_count]
        # update the old data to reflect the current metric
        # since we are caching and don't want to return the same
        # counter value every minute.
        old_data.merge(data)
        count > 0 ? count : 0
      end
    end

    def configure(options)
      @url = "http://twitter.com/#{options[:username]}"
    end

    private

    def self.data
      # Cache the data for 15 minutes, we don't really need it every minute.
      if !@time || @time < Time.now - 900
        logger.debug "Fetching data at #{Time.now}"
        @old_data = @data || Hash.new(1_000_000_000)
        @data = instance.send(:data)
        @time = Time.now
      end
      @data
    end
    
    def self.old_data
      @old_data
    end

    def data
      begin
        html = open(@url)
        doc = Nokogiri::HTML(html)

        %w(following_count follower_count update_count).inject({}) do |result, metric|
          txt = doc.css("\##{metric}").inner_text
          result[metric.to_sym] = Integer(txt.gsub(/\D/, ''))
          result
        end
      rescue Exception => e
        logger.error "Error contacting #{@url}"
        logger.error "#{e.class.name}: #{e.message}"
        Hash.new(0)
      end
    end

  end
end
