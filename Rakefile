require_relative './lib/requires'
require_relative './lib/tasks/lint/high_priority'

task run: %i[global_stats navigation_page_quality]

task :global_stats do
  GlobalStats.new.run
end

task :navigation_page_quality do
  NavigationPageQuality.new.run
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
