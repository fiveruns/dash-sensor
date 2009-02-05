require 'open-uri'

module Dash::Sensor::Plugins
  class Apache
    include SensorPlugin
    
    ONE_KB = 1024

    register :apache, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.counter :requests, 'Requests' do
        total = Integer(stats['Total Accesses'])
        last = Integer(old_stats['Total Accesses'])
        this_minute = total - last
        puts "requests: #{this_minute}"
        this_minute > 0 && last > 0 ? this_minute : 0
      end
      recipe.counter :mbytes, 'Transferred', :unit => 'MB' do
        total = Integer(stats['Total kBytes'])
        last = Integer(old_stats['Total kBytes'])
        this_minute = Float(total - last) / ONE_KB
        puts "bytes: #{this_minute}"
        this_minute > 0 && last > 0 ? this_minute : 0
      end
    end
    
    def configure(options)
      @url = options.fetch(:url, 'http://localhost/server-status?auto')
    end

    private

    def self.stats
      if !@time || @time < Time.now - 55
        @old_stats = @stats || {}
        puts "Fetching status at #{Time.now}"
        @stats = instance.send(:stats_data)
        @time = Time.now
      end
      @stats
    end
    
    def self.old_stats
      @old_stats
    end

    def stats_data
      data = ''
      
      begin
        lines = open(@url).read.split("\n")
        Hash[*lines.map {|line| line.split(':') }.flatten]
      rescue => e
        puts "Error contacting #{@url}"
        puts "#{e.class.name}: #{e.message}"
        Hash.new(0)
      end
    end

  end
end