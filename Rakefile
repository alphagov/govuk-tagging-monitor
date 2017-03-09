require 'typhoeus'
require 'json'
require 'statsd'
require 'nokogiri'

require_relative './lib/stats_helpers'
require_relative './lib/services'
require_relative './lib/http'
require_relative './lib/global_stats'
require_relative './lib/navigation_page_quality'

task run: %i[global_stats navigation_page_quality]

task :global_stats do
  GlobalStats.new.run
end

task :navigation_page_quality do
  NavigationPageQuality.new.run
end
