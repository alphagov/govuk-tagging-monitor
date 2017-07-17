require 'spec_helper'

RSpec.describe Linters::Taxons::BlueBoxCountLinter, '#lint' do
  context 'linting a taxon with child taxons and no grandchildren' do
    before(:each) do
      @taxon = Taxon.new(
        '/root-taxon',
        0,
        [
          Taxon.new('/child-taxon', 1, [])
        ],
      )
    end

    context 'with a linter checking for !=5 blue box links' do
      before(:each) do
        @linter = Linters::Taxons::BlueBoxCountLinter.warn_if_not_equal_to(5)
      end

      it 'warns with fewer than 5 blue box links' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(
          number_of_sections: 1,
          number_of_content_items: 1,
          number_of_blue_box_links: 3
        )

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          "Blue box section has 3 links to content items (which is !=5)"
        )
      end

      it 'warns with more than 5 blue box links' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(
          number_of_sections: 1,
          number_of_content_items: 1,
          number_of_blue_box_links: 10
        )

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          "Blue box section has 10 links to content items (which is !=5)"
        )
      end

      it 'does not warn when there are exactly 5 blue box links' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(
          number_of_sections: 1,
          number_of_content_items: 1,
          number_of_blue_box_links: 5
        )

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end
  end
end
