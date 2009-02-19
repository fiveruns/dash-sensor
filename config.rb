# Example configuration for FiveRuns Dash Sensor daemon.
# Configure your Dash sensor instance here.
# This file should reside in ~/.fiveruns-dash-sensor/config.rb
#
# We suggest you have a single Dash Sensor instance running per machine
# and an application token per environment.  So if you have 8 machines
# in your application's production cluster, you would have 8 sensor instances
# running for one application named "<App> Production Cluster".

#sensor.token = 'change-to-your-application-token'

# One line per piece of infrastructure you wish to monitor.
# The plugins are in the plugins directory.

# Available options and their defaults are listed.
#sensor.plugin 'memcached', :iface => 'localhost', :port => 11211
#sensor.plugin 'starling', :iface => 'localhost', :port => 22122
#sensor.plugin 'apache', :url => 'http://localhost/server-status?auto'
#sensor.plugin 'nginx', :url => 'http://localhost/nginx_status'
#
# Collect a few social network metrics from Twitter
#sensor.plugin 'twitter', :username => 'my_username'
#
# Collect some real-time weather metrics from NOAA.
# Format should be 'metric' or 'english'
# Station should be the four letter station ID.  Find your local station here:
# http://www.weather.gov/xml/current_obs/
#
#sensor.plugin 'noaa_weather', :format => 'metric', :station => 'katt'
