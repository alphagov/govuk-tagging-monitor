module Services
  def self.statsd
    @statsd ||= Statsd.new
  end

  def self.rummager
    @rummager ||= GdsApi::Rummager.new(
      Plek.new.find('rummager')
    )
  end

  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end
end
