module Dash::Sensor::Plugins
  class Varnish
    include SensorPlugin

    register :varnish, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.percentage :hit_rate, 'Cache Hit Rate %' do
        hits = stats['cache_hit']
        miss = stats['cache_miss']
        total = hits + miss
        total > 0 ? (Float(hits) / total * 100) : 0
      end
      recipe.absolute :requests, 'Requests' do
        prev = old_stats['client_req']
        now = stats['client_req']
        prev > 0 ? now - prev : 0
      end
    end
    
    def configure(options)
      @binary = options.fetch(:varnishstat, 'varnishstat')
    end

    private

    def self.stats
      if !@time || @time < Time.now - 55
        logger.debug "Fetching stats at #{Time.now}"
        @old_stats = @stats || Hash.new(0)
        @stats = instance.send(:stats_data)
        @time = Time.now
      end
      @stats
    end
    
    def self.old_stats
      @old_stats
    end

    def stats_data
      output = `#{@binary} -1 2>&1`
      metrics = Hash.new(0)
      output.each_line do |line|
        case line
        when /^(\w+)\s+(\d+)/
          metrics[$1] = Integer($2)
        else
          Dash::Sensor::Engine.logger.warn "Unexpected output from #{@binary}: #{line}"
        end
      end
      metrics
    end

  end
end
