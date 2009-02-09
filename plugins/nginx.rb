require 'open-uri'

module Dash::Sensor::Plugins
  class Nginx
    include SensorPlugin
    
    ONE_KB = 1024

    register :nginx, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.counter :requests, 'Requests' do
        total = stats[:requests]
        last = old_stats[:requests]
        this_minute = total - last
        this_minute > 0 && last > 0 ? this_minute : 0
      end
      recipe.absolute :connections, 'Active Connections' do
        stats[:active]
      end
    end
    
    def configure(options)
      @url = options.fetch(:url, 'http://localhost/nginx-status')
    end

    private

    def self.stats
      if !@time || @time < Time.now - 55
        @old_stats = @stats || Hash.new(0)
        logger.debug "Fetching status at #{Time.now}"
        @stats = instance.send(:stats_data)
        @time = Time.now
      end
      @stats
    end
    
    def self.old_stats
      @old_stats
    end

    def stats_data
      begin
        results = Hash.new(0)
        data = open(@url).read
        data.each_line do |line|
          case line
          when /^Active connections:\s+(\d+)/
            results[:active] = Integer($1)
          when /^\s+(\d+)\s+(\d+)\s+(\d+)/
            results[:requests] = Integer($3)
          end
        end
        results
      rescue Exception => e
        logger.error "Error contacting #{@url}"
        logger.error "#{e.class.name}: #{e.message}"
        Hash.new(0)
      end
    end

  end
end
