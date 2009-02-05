Gem::Specification.new do |s|
	s.name = "fiveruns_dash_sensor"
	s.version = "0.8.0"
	s.authors = "FiveRuns"
	s.email = "support@fiveruns.com"
	s.homepage = "http://github.com/fiveruns/fiveruns_dash_sensor/"
	s.summary = "Sensor allows Dash to monitor ad-hoc infrastructure non-invasively"
	s.description = s.summary

	s.require_path = 'lib'

	# get this easily and accurately by running 'Dir.glob("{bin,config,lib,plugins}/**/*")'
	# in an IRB session.  However, GitHub won't allow that command hence
	# we spell it out.
	s.files = ["bin/dash-sensor", "config/setup.rb", "lib/daemon.rb", "lib/sensor.rb", "plugins/memcached.rb"]
	s.test_files = []
	s.extra_rdoc_files = ["README.rdoc", "History.rdoc"]

end
