module StatsHelpers
  def gauge(stat, value)
    puts "GAUGE: govuk.tagging.#{stat}: #{value}"
    Services.statsd.gauge("govuk.tagging.#{stat}", value)
  end
end
