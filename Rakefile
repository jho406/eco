require 'rake/testtask'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'eco'

Rake::TestTask.new do |t|
 t.libs << 'spec'
 t.pattern = 'spec/**/*_spec.rb'
end

desc "load Data.yaml and run simulations"
task :simulate do
  loader = Eco::Loader.new('./Data.yml')
  simulations = loader.load(Eco::Simulator)
  simulations.each do |sim|
    sim.run
    puts Eco::Utils.render_stats(sim.stats)
  end
end

task :default => :test
