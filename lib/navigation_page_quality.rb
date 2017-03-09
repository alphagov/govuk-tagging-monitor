class NavigationPageQuality
  include StatsHelpers

  def run
    warnings = []

    education = HTTP.get("https://www.gov.uk/api/content/education")
    all_taxon_base_paths = Flatten.new(education).flattened

    gauge "navigation_pages.count", all_taxon_base_paths.size

    navigation_urls = all_taxon_base_paths.map do |base_path|
      "https://www.gov.uk#{base_path}"
    end

    pages = HTTP.get_multiple(navigation_urls)

    pages.map do |url, page|
      doc = Nokogiri::HTML(page)

      page_type = doc.css('meta[name="govuk:navigation-page-type"]').attr("content").to_s
      size = doc.css('.topic-content ol li').size

      if page_type == "leaf" && size == 0
        warnings << "#{url} has no tagged content shown"
      end

      size
    end

    if warnings.any?
      message_payload = {
        username: "Sad Parrot",
        icon_emoji: ":sadparrot:",
        text: "Oh no, there's a problem with some navigation pages:\n\n#{warnings.join("\n")}",
        mrkdwn: true,
        channel: '#finding-things',
      }

      HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))
    end
  end

  class Flatten
    attr_reader :content_item

    def initialize(content_item)
      @content_item = content_item
    end

    def flattened
      flatten_recursively(content_item).flatten
    end

    def flatten_recursively(content_item)
      content_item.dig("links", "child_taxons").to_a.map do |content_item|
        [content_item["base_path"]] + flatten_recursively(content_item)
      end
    end
  end
end
