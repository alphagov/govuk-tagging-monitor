require 'typhoeus'
require 'json'
require 'statsd'

module Services
  def self.statsd
    @statsd ||= Statsd.new
  end
end

def get(url)
  response = Typhoeus.get(url)
  JSON.parse(response.body)
end

def gauge(stat, value)
  puts "GAUGE: govuk.tagging.#{stat}: #{value}"
  Services.statsd.gauge("govuk.tagging.#{stat}", value)
end

task :run do
  total_items = get("https://www.gov.uk/api/search.json?count=0&debug=include_withdrawn")
  gauge "items", total_items.fetch("total")

  untagged_items = get("https://www.gov.uk/api/search.json?count=0&filter_taxons=_MISSING&debug=include_withdrawn")
  gauge "items_without_taxons", untagged_items.fetch("total")

  gauge "items_with_taxons", total_items.fetch("total") - untagged_items.fetch("total")
end
