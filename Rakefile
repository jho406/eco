require 'rake/testtask'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'eco'

Rake::TestTask.new do |t|
 t.libs << 'spec'
 t.pattern = 'spec/**/*_spec.rb'
end

task :default => :test
