module Dash::Sensor::Plugins
  class Memcached
    include SensorPlugin

    register :memcached, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.absolute :bytes, 'Cache Size', :unit => 'MB' do
        Float(stats['bytes']) / (1024 * 1024)
      end
      recipe.percentage :hit_rate, 'Cache Hit Rate' do
        hits = Integer(stats['get_hits'])
        misses = Integer(stats['get_misses'])
        total = hits + misses
        total == 0 ? 0 : ((Float(hits) / total) * 100)
      end
    end

    def configure(options)
      @host = options.fetch(:iface, 'localhost')
      @port = Integer(options.fetch(:port, 11211))
    end

    private
    
    def self.stats
      if !@time || @time < Time.now - 55
        LOG.debug "Fetching stats at #{Time.now}"
        @stats = parse(instance.send(:stats_data))
        @time = Time.now
      end
      @stats
    end

    def stats_data
      data = ''
      begin
        sock = TCPSocket.new(@host, @port)
        sock.print("stats\r\n")
        sock.flush
        # memcached does not close the socket once it is done writing
        # the stats data.  We need to read line by line until we detect
        # the END line and then stop/close on our side.
        stats = sock.gets
        while true
          data += stats
          break if stats.strip == 'END'
          stats = sock.gets
        end
        sock.close
      rescue Exception => e
        LOG.error "Error contacting Starling at #{@host}:#{@port}"
        LOG.error "#{e.class.name}: #{e.message}"
      end
      data
    end

    def self.parse(stats_data)
      stats = Hash.new(0)
      stats_data.each_line do |line|
        stats[$1] = $2 if line =~ /STAT (\w+) (\S+)/
      end
      stats
    end

  end
end