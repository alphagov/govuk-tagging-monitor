module Services
  def self.statsd
    @statsd ||= Statsd.new
  end
end
