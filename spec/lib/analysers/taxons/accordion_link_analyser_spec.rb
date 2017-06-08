require 'spec_helper'

RSpec.describe Analysers::Taxons::AccordionLinkAnalyser, '#analyse' do
  context 'analysing a taxon with child taxons and no grandchildren' do
    before(:each) do
      @taxon = Taxon.new(
        '/root-taxon',
        0,
        [
          Taxon.new('/child-taxon-1', 1, []),
          Taxon.new('/child-taxon-2', 1, []),
        ],
      )
      @analyser = Analysers::Taxons::AccordionLinkAnalyser.new
    end

    context 'with 2 content items tagged to each section' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 2, number_of_content_items: 2)
      end

      it 'returns each of the taxon links' do
        results = @analyser.analyse(@taxon)
        expect(results).to contain_exactly(
          {
            taxon_base_path: '/root-taxon',
            link_href: '/path-0-0',
            total_number_of_links_per_section: 2,
            navigation_page_type: 'accordion',
            section: 'Subsection 0',
            number_of_tags: 1,
            taxon_base_paths: "taxon-0"
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/path-0-1',
            total_number_of_links_per_section: 2,
            navigation_page_type: 'accordion',
            section: 'Subsection 0',
            number_of_tags: 1,
            taxon_base_paths: "taxon-0"
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/path-1-0',
            total_number_of_links_per_section: 2,
            navigation_page_type: 'accordion',
            section: 'Subsection 1',
            number_of_tags: 1,
            taxon_base_paths: "taxon-1"
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/path-1-1',
            total_number_of_links_per_section: 2,
            navigation_page_type: 'accordion',
            section: 'Subsection 1',
            number_of_tags: 1,
            taxon_base_paths: "taxon-1"
          },
        )
      end
    end

    context 'with 0 content items tagged to each section' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 2, number_of_content_items: 0)
      end

      it 'does not return any results' do
        results = @analyser.analyse(@taxon)
        expect(results).to be_empty
      end
    end
  end

  context 'analysing a taxon with grandchildren' do
    before(:each) do
      @taxon = Taxon.new(
        '/root-taxon',
        0,
        [
          Taxon.new('/child-taxon', 1, [
            Taxon.new('/grandchild-taxon', 2, [])
          ]),
        ],
      )
      @analyser = Analysers::Taxons::AccordionLinkAnalyser.new
    end

    context 'with 2 content items tagged to each section' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_grid_content_items(number_of_taxons: 2, number_of_content_items: 2)
      end

      it 'returns no results' do
        results = @analyser.analyse(@taxon)
        expect(results).to be_empty
      end
    end
  end

  context 'analysing a taxon with no children' do
    before(:each) do
      @taxon = Taxon.new(
        '/root-taxon',
        0,
        [],
      )
      @analyser = Analysers::Taxons::AccordionLinkAnalyser.new
    end

    context 'with 2 content items tagged to each section' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 2)
      end

      it 'returns no results' do
        results = @analyser.analyse(@taxon)
        expect(results).to be_empty
      end
    end
  end
end
