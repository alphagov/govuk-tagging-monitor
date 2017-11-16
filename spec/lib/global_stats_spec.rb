require 'spec_helper'

RSpec.describe GlobalStats do
  before do
    allow(Services.statsd).to receive(:gauge)
  end

  describe '#run' do
    it "reports statistics" do

      stub_request(:get, "https://www.gov.uk/api/search.json").
        with(query: { count: 0,
                      debug: 'include_withdrawn' }).
        to_return(body: JSON.dump(total: 1000))

      stub_request(:get, "https://www.gov.uk/api/search.json").
        with(query: { count: 0,
                      debug: 'include_withdrawn',
                      reject_content_store_document_type: GlobalStats::BLACKLIST_DOCUMENT_TYPES }).
        to_return(body: JSON.dump(total: 500))

      stub_request(:get, "https://www.gov.uk/api/search.json").
        with(query: { count: 0,
                      debug: 'include_withdrawn',
                      filter_taxons: '_MISSING',
                      reject_content_store_document_type: GlobalStats::BLACKLIST_DOCUMENT_TYPES }).
        to_return(body: JSON.dump(total: 100))

      GlobalStats.new.run

      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.items", 1000)
      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.items_without_taxons", 100)
      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.taggable_items", 500)
      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.items_with_taxons", 400)
    end
  end
end
