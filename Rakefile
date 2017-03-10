require_relative './lib/requires'

task run: %i[global_stats navigation_page_quality]

task :global_stats do
  GlobalStats.new.run
end

task :navigation_page_quality do
  NavigationPageQuality.new.run
end
