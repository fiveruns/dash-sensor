Gem::Specification.new do |s|
	s.name = "dash-sensor"
	s.version = "0.8.0"
	s.authors = "FiveRuns"
	s.email = "support@fiveruns.com"
	s.homepage = "http://github.com/fiveruns/dash-sensor/"
	s.summary = "Sensor allows Dash to monitor ad-hoc infrastructure non-invasively"
	s.description = s.summary

	s.require_path = 'lib'

	# get this easily and accurately by running 'Dir.glob("{bin,config,lib,plugins}/**/*")'
	# in an IRB session.  However, GitHub won't allow that command hence
	# we spell it out.
	s.files = ["bin/fiveruns-dash-sensor", "config.rb", "lib/daemon.rb", "lib/sensor.rb", "lib/sensor_plugin.rb", "plugins/memcached.rb", "plugins/starling.rb", "plugins/nginx.rb", "plugins/apache.rb"]
	s.test_files = []
	s.extra_rdoc_files = ["README.rdoc", "History.rdoc"]
	s.executables = ["fiveruns-dash-sensor"]

end
