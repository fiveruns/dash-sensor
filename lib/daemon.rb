require 'ostruct'
require 'optparse'

# Sent by daemons when you run '<script> stop'
Signal.trap('TERM') { puts "fiveruns-dash-sensor PID #{$$} exiting at #{Time.now}..."; exit(0) }
# Sent by daemons when you hit Ctrl-C after '<script> run'
Signal.trap('INT') { puts "fiveruns-dash-sensor terminated at #{Time.now}..."; exit(0) }

options = OpenStruct.new
options.environment = ENV['RAILS_ENV'] || 'production'
options.verbose = false
options.config_file = "#{ENV['HOME']}/.fiveruns-dash-sensor/config.rb"

op = OptionParser.new do |opts|
  opts.banner = "Usage: fiveruns-dash-sensor [options]"
  opts.separator "General Options:"
  opts.on("-e ENVIRONMENT", "--environment NAME", "Select environment [default: #{options.environment}]") do |v|
    options.environment = v
  end
  opts.on("-c CONFIG", "--config FILE", "Select config file [default: #{options.config_file}]") do |v|
    options.config_file = v
  end
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options.verbose = v
  end
  opts.separator "Other Options:"
  opts.on("-h", "--help", "Display this message") do |v|
    STDERR.puts opts
    exit
  end
end
op.parse!(ARGV)

unless File.exist? options.config_file
  puts "Please create a configuration file for your environment in ~/.fiveruns-dash-sensor/config.rb"
  exit(1)
end

require 'logger'
LOG = Logger.new(STDOUT)
LOG.level = options.verbose ? Logger::DEBUG : Logger::INFO

$LOAD_PATH.unshift File.dirname(__FILE__)
require "sensor"
LOG.info("Starting Dash Sensor [#{$$}] at #{Time.now}")
Dash::Sensor::Engine.new.start(options)
