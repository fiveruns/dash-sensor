require 'open-uri'

begin
  require 'nokogiri'
rescue LoadError => le
  puts [
    "The NOAA weather plugin requires the nokogiri gem.  Install with:",
    "   sudo gem install nokogiri"
    ].join("\n")
  raise le
end

# Collect the temperature and air pressure as reported by NOAA and send them to Dash.
# Proof that Sensor and Dash work with more than boring old software metrics.
# They work with boring real life metrics too.  :-)
module Dash::Sensor::Plugins
  class NoaaWeather
    include SensorPlugin

    register :noaa_weather, :url => 'http://dash.fiveruns.com' do |recipe|
      recipe.absolute :temperature do
        data[:temperature]
      end
      recipe.absolute :pressure do
        data[:pressure]
      end
    end

    def configure(options)
      @url = "http://www.weather.gov/data/current_obs/#{options.fetch(:station, 'katt').upcase}.xml"
      format = options.fetch(:format, 'metric')
      case format.to_s
      when 'metric'
        @temp_format = 'c'
        @pres_format = 'mb'
      when 'english'
        @temp_format = 'f'
        @pres_format = 'in'
      else
        raise ArgumentError, "Unknown format '#{format}', must be either be :metric or :english"
      end
    end

    private

    def self.data
      # Cache the data for 15 minutes, we don't really need it every minute.
      if !@time || @time < Time.now - 900
        logger.debug "Fetching data at #{Time.now}"
        @data = instance.send(:data)
        @time = Time.now
      end
      @data
    end
    
    def data
      begin
        xml = open(@url)
        doc = Nokogiri::XML(xml)

        result = {}
        result[:temperature] = Float(doc.xpath("/current_observation/temp_#{@temp_format}").inner_text)
        result[:pressure] = Float(doc.xpath("/current_observation/pressure_#{@pres_format}").inner_text)
        result
      rescue Exception => e
        logger.error "Error contacting #{@url}"
        logger.error "#{e.class.name}: #{e.message}"
        Hash.new(0)
      end
    end

  end
end
