# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dash-sensor}
  s.version = "0.8.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["FiveRuns Development Team"]
  s.date = %q{2009-03-02}
  s.default_executable = %q{fiveruns-dash-sensor}
  s.description = %q{Daemon to monitor ad-hoc infrastructure non-invasively for FiveRuns Dash}
  s.email = %q{dev@fiveruns.com}
  s.executables = ["fiveruns-dash-sensor"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/fiveruns-dash-sensor", "lib/runner.rb", "lib/sensor.rb", "lib/sensor_plugin.rb", "plugins/apache.rb", "plugins/memcached.rb", "plugins/nginx.rb", "plugins/noaa_weather.rb", "plugins/starling.rb", "plugins/twitter.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/fiveruns/dash-sensor/}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FiveRuns Sensor allows Dash to monitor ad-hoc infrastructure non-invasively}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fiveruns-dash-ruby>, [">= 0.8.2"])
    else
      s.add_dependency(%q<fiveruns-dash-ruby>, [">= 0.8.2"])
    end
  else
    s.add_dependency(%q<fiveruns-dash-ruby>, [">= 0.8.2"])
  end
end
