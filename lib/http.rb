module HTTP
  HEADERS = {
    "User-Agent" => "GOV.UK Tagging Monitoring / https://github.com/alphagov/govuk-tagging-monitor",
    "Rate-Limit-Token" => ENV['RATE_LIMIT_TOKEN'],
  }

  def self.get_json(url)
    response = HTTP.get(url)
    JSON.parse(response)
  end

  def self.get(url)
    Typhoeus.get(url, headers: HEADERS).body
  end

  def self.post(url, body:)
    response = Typhoeus.post(url, body: body, headers: HEADERS)
    response.body
  end

  def self.get_multiple(urls)
    hydra = Typhoeus::Hydra.new

    requests = urls.map do |url|
      request = Typhoeus::Request.new(url, headers: HEADERS)
      hydra.queue(request)
      [url, request]
    end

    hydra.run

    requests.reduce({}) do |h, (url, request)|
      if request.response.success?
        h[url] = request.response.body
      else
        puts "-> #{url}: #{request.response.response_code}"
      end
      h
    end
  end
end
