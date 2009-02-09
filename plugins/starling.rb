module Dash::Sensor::Plugins
  class Starling
    include SensorPlugin

    register :starling, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.absolute :processed, 'Processed Items' do
        queues = stats.keys.map { |name| name =~ /queue_(\w+)_total_items/; $1 }.compact
        queues.inject(0) { |total, queue_name| total + Integer(stats["queue_#{queue_name}_total_items"]) - Integer(stats["queue_#{queue_name}_items"]) }
      end
      recipe.absolute :queue_size, 'Current Size' do
        queues = stats.keys.find_all { |name| name =~ /queue_([^_]+?)_items/ }
        queues.inject(0) { |total, queue_name| total + Integer(stats[queue_name]) }
      end
    end
    
    def configure(options)
      @host = options.fetch(:iface, 'localhost')
      @port = Integer(options.fetch(:port, 22122))
    end

    private

    def self.stats
      if !@time || @time < Time.now - 55
        logger.debug "Fetching stats at #{Time.now}"
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
        logger.error "Error contacting Starling at #{@host}:#{@port}"
        logger.error "#{e.class.name}: #{e.message}"
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
