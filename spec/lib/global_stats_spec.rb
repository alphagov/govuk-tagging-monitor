require 'spec_helper'

RSpec.describe GlobalStats do
  before do
    allow(Services.statsd).to receive(:gauge)
  end

  describe '#run' do
    it "reports statistics" do
      stub_request(:get, "https://www.gov.uk/api/search.json?count=0&debug=include_withdrawn").
        to_return(body: JSON.dump(total: 123))

      stub_request(:get, "https://www.gov.uk/api/search.json?count=0&debug=include_withdrawn&filter_taxons=_MISSING").
        to_return(body: JSON.dump(total: 100))

      GlobalStats.new.run

      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.items", 123)
      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.items_without_taxons", 100)
      expect(Services.statsd).to have_received(:gauge).with("govuk.tagging.items_with_taxons", 23)
    end
  end
end
