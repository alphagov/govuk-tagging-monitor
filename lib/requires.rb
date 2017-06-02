require 'typhoeus'
require 'json'
require 'statsd'
require 'nokogiri'

require_relative './stats_helpers'
require_relative './services'
require_relative './http'
require_relative './global_stats'
require_relative './css_selector'
require_relative './taxonomy_visitor'
require_relative './taxon'
require_relative './linters/taxonomy_linter'
require_relative './linters/taxons/count_linter'
require_relative './linters/taxons/depth_count_linter'
require_relative './linters/taxons/content_item_counter'
require_relative './linters/taxons/accordion_count_linter'
require_relative './linters/taxons/leaf_count_linter'
require_relative './linters/taxons/depth_count_linter'
require_relative './analysers/taxonomy_analyser'
require_relative './analysers/taxons/accordion_link_analyser'
require_relative './analysers/taxons/grid_and_leaf_link_analyser'
require_relative './notifiers/slack'
