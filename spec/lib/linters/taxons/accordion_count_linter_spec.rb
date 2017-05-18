require 'spec_helper'

RSpec.describe Linters::Taxons::AccordionCountLinter, '#lint' do
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

    context 'with a linter checking for ==0 content items' do
      before(:each) do
        @linter = Linters::Taxons::AccordionCountLinter.warn_if_equal_to(0)
      end

      it 'warns for subsections with 0 content items' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 1, number_of_content_items: 0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          "Accordion subsection 'Subsection 0' has 0 content items tagged (which is ==0)"
        )

      end

      it 'does not warn for taxons with 5 content item' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 1,number_of_content_items: 5)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end

    context 'with a linter checking for >20 content items' do
      before(:each) do
        @linter = Linters::Taxons::AccordionCountLinter.warn_if_greater_than(20)
      end

      it 'does not warn for taxons with 5 content item' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 1, number_of_content_items: 5)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end

      it 'warns for taxons with 25 content items' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 1, number_of_content_items: 25)

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          "Accordion subsection 'Subsection 0' has 25 content items tagged (which is >20)"
        )
      end
    end
  end

  context 'linting a taxon with grandchild taxons' do
    before(:each) do
      @taxon = Taxon.new(
        '/base-path',
        0,
        [
          Taxon.new(
            '/child-taxon',
            1,
            [
              Taxon.new('/grandchild-taxon', 2)
            ]
          )
        ],
      )
    end

    context 'with a linter checking for ==0 content items' do
      before(:each) do
        @linter = Linters::Taxons::AccordionCountLinter.warn_if_equal_to(0)
      end

      it 'does not warn for taxons with 0 content items' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 0, number_of_content_items: 0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end
  end

  context 'linting a taxon with no child taxons' do
    before(:each) do
      @taxon = Taxon.new(
        '/base-path',
        0,
      )
    end

    context 'with a linter checking for ==0 content items' do
      before(:each) do
        @linter = Linters::Taxons::AccordionCountLinter.warn_if_equal_to(0)
      end

      it 'does not warn for taxons with 0 content items' do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 0, number_of_content_items: 0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end
  end
end
