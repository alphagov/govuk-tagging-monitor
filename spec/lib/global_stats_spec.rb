require 'spec_helper'

RSpec.describe GlobalStats do
  before do
    allow(Services.statsd).to receive(:gauge)
  end

  describe '#run' do
    it "reports statistics" do
      stub_request(:get, "http://rummager.dev.gov.uk/search.json")
        .with(query: {
          count: 0,
          debug: 'include_withdrawn'
        }).to_return(body: JSON.dump(total: 1000))

      stub_request(:get, "http://rummager.dev.gov.uk/search.json")
        .with(query: {
          count: 0,
          debug: 'include_withdrawn',
          reject_content_store_document_type: GlobalStats::BLACKLIST_DOCUMENT_TYPES
        }).to_return(body: JSON.dump(total: 500))

      stub_request(:get, "http://publishing-api.dev.gov.uk/v2/links/f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a")
        .to_return(body: JSON.dump(links: { root_taxons: ['aaaa-bbbb', 'cccc-dddd'] }))

      stub_request(:get, "http://rummager.dev.gov.uk/search.json")
        .with(query: {
          count: 0,
          debug: 'include_withdrawn',
          filter_part_of_taxonomy_tree: ['aaaa-bbbb', 'cccc-dddd'],
          reject_content_store_document_type: GlobalStats::BLACKLIST_DOCUMENT_TYPES
        }).to_return(body: JSON.dump(total: 400))

      GlobalStats.new.run

      expect(Services.statsd).to have_received(:gauge)
        .with("govuk.tagging.items", 1000)

      expect(Services.statsd).to have_received(:gauge)
        .with("govuk.tagging.taggable_items", 500)

      expect(Services.statsd).to have_received(:gauge)
        .with("govuk.tagging.taggable_items_with_taxons", 400)

      expect(Services.statsd).to have_received(:gauge)
        .with("govuk.tagging.taggable_items_without_taxons", 100)
    end
  end
end
