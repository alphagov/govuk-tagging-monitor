module Services
  def self.statsd
    @statsd ||= Statsd.new
  end

  def self.rummager
    GdsApi::Rummager.new('https://www.gov.uk/api')
  end
end
