require 'spec_helper'

RSpec.describe Linters::Taxons::LeafCountLinter, '#lint' do
  context 'linting a taxon with no child taxons' do
    before(:each) do
      @taxon = Taxon.new(
        '/base-path',
        0,
        [],
      )
    end

    context 'with a linter checking for ==0 content items' do
      before(:each) do
        @linter = Linters::Taxons::LeafCountLinter.warn_if_equal_to(0)
      end

      it 'warns for taxons with 0 content items' do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          '0 content items tagged (which is ==0)'
        )

      end

      it 'does not warn for taxons with 5 content item' do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 5)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end

    context 'with a linter checking for >20 content items' do
      before(:each) do
        @linter = Linters::Taxons::LeafCountLinter.warn_if_greater_than(20)
      end

      it 'does not warn for taxons with 5 content item' do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 5)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end

      it 'warns for taxons with 25 content items' do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 25)

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          '25 content items tagged (which is >20)'
        )
      end
    end
  end

  context 'linting a taxon with child taxons' do
    before(:each) do
      @taxon = Taxon.new(
        '/base-path',
        0,
        [
          Taxon.new('/child-taxon',1)
        ],
      )
    end

    context 'with a linter checking for ==0 content items' do
      before(:each) do
        @linter = Linters::Taxons::LeafCountLinter.warn_if_equal_to(0)
      end

      it 'does not warn for taxons with 0 content items' do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end
  end
end
