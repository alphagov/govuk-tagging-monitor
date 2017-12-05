require_relative './lib/requires'
require_relative './lib/tasks/lint/high_priority'
require_relative './lib/tasks/lint/low_priority'
require_relative './lib/tasks/analyse/links'

namespace :check do
  task high_priority: %i[lint:high_priority]
  task low_priority: %i[lint:low_priority]
end

task run: %i[check:high_priority]

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
