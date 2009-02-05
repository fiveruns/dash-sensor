# Example configuration for FiveRuns Dash Sensor daemon.
# Configure your Dash sensor instance here and copy this file
# to ~/.fiveruns_dash_sensor/config.rb
#
# We suggest you have a single Dash Sensor instance running per machine
# and an application token per environment.  So if you have 8 machines
# in your application's production cluster, you would have 8 sensor instances
# running for one application named "<App> Production Cluster".

sensor.url = 'http://localhost:3000'

sensor.name = 'My App'
sensor.token = 'change-to-your-application-token'

# One line per piece of infrastructure you wish to monitor.
# The plugins are in the plugins directory.

# Available options and their defaults are listed.
sensor.plugin 'memcached', :iface => 'localhost', :port => 11211
#sensor.plugin 'apache'
#sensor.plugin 'nginx'
#sensor.plugin 'haproxy'
#sensor.plugin 'mysql'