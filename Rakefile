require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "dash-sensor"
    s.summary = %Q{FiveRuns Sensor allows Dash to monitor ad-hoc infrastructure non-invasively}
    s.email = "dev@fiveruns.com"
    s.homepage = "http://github.com/fiveruns/dash-sensor/"
    s.description = "Daemon to monitor ad-hoc infrastructure non-invasively for FiveRuns Dash"
    s.authors = ["FiveRuns Development Team"]
    s.add_dependency('fiveruns-dash-ruby', '>= 0.8.2')
    s.files = FileList["[A-Z]*.*", "{bin,lib,plugins,test}/**/*"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'dash-sensor'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
end

task :default => :test
