require 'spec_helper'

RSpec.describe Analysers::Taxons::GridAndLeafLinkAnalyser, '#analyse' do
  context 'analysing a taxon with grandchildren' do
    before(:each) do
      @taxon = Taxon.new(
        '/root-taxon',
        0,
        [
          Taxon.new('/child-taxon', 1, [
            Taxon.new('/grandchild-taxon', 2, []),
          ]),
        ],
      )
      @analyser = Analysers::Taxons::GridAndLeafLinkAnalyser.new
    end

    context 'with 2 child taxons and 0 content items tagged' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_grid_content_items(number_of_taxons: 2, number_of_content_items: 0)
      end

      it 'finds 2 taxon links' do
        results = @analyser.analyse(@taxon)

        expect(results).to contain_exactly(
          {
            taxon_base_path: '/root-taxon',
            link_href: '/taxon-0',
            total_number_of_links: 2,
            total_number_of_links_per_section: 'N/A',
            navigation_page_type: 'grid',
            section: 'grid',
            number_of_tags: 'N/A',
            taxon_base_paths: 'N/A'
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/taxon-1',
            total_number_of_links: 2,
            total_number_of_links_per_section: 'N/A',
            navigation_page_type: 'grid',
            section: 'grid',
            number_of_tags: 'N/A',
            taxon_base_paths: 'N/A'
          },
        )
      end
    end

    context 'with 2 child taxons and 2 content items tagged' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_grid_content_items(number_of_taxons: 2, number_of_content_items: 2)
      end

      it 'finds 2 taxon links and 2 leaf links' do
        results = @analyser.analyse(@taxon)

        expect(results).to contain_exactly(
          {
            taxon_base_path: '/root-taxon',
            link_href: '/taxon-0',
            total_number_of_links: 2,
            total_number_of_links_per_section: "N/A",
            navigation_page_type: 'grid',
            section: 'grid',
            number_of_tags: 'N/A',
            taxon_base_paths: 'N/A'
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/taxon-1',
            total_number_of_links: 2,
            total_number_of_links_per_section: "N/A",
            navigation_page_type: 'grid',
            section: 'grid',
            number_of_tags: 'N/A',
            taxon_base_paths: 'N/A'
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/content-item-0',
            total_number_of_links: 2,
            total_number_of_links_per_section: "N/A",
            navigation_page_type: 'grid',
            section: 'leaf',
            number_of_tags: 1,
            taxon_base_paths: 'taxon-0'
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/content-item-1',
            total_number_of_links: 2,
            total_number_of_links_per_section: "N/A",
            navigation_page_type: 'grid',
            section: 'leaf',
            number_of_tags: 1,
            taxon_base_paths: 'taxon-1'
          },
        )
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
      @analyser = Analysers::Taxons::GridAndLeafLinkAnalyser.new
    end

    context 'with 2 content items tagged' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_content_items(number_of_content_items: 2)
      end

      it 'finds 2 leaf links' do
        results = @analyser.analyse(@taxon)

        expect(results).to contain_exactly(
          {
            taxon_base_path: '/root-taxon',
            link_href: '/content-item-0',
            total_number_of_links: 2,
            total_number_of_links_per_section: "N/A",
            navigation_page_type: 'leaf',
            section: 'leaf',
            number_of_tags: 1,
            taxon_base_paths: 'taxon-0'
          },
          {
            taxon_base_path: '/root-taxon',
            link_href: '/content-item-1',
            total_number_of_links: 2,
            total_number_of_links_per_section: "N/A",
            navigation_page_type: 'leaf',
            section: 'leaf',
            number_of_tags: 1,
            taxon_base_paths: 'taxon-1'
          },
        )
      end
    end
  end

  context 'analysing a taxon with children, but no grandchildren' do
    before(:each) do
      @taxon = Taxon.new(
        '/root-taxon',
        0,
        [
          Taxon.new('/child-taxon', 1, []),
        ],
      )
      @analyser = Analysers::Taxons::GridAndLeafLinkAnalyser.new
    end

    context 'with 2 content items tagged' do
      before(:each) do
        @taxon.body_html = BodyHtml.with_accordion_content_items(number_of_sections: 1, number_of_content_items: 2)
      end

      it 'returns no results' do
        results = @analyser.analyse(@taxon)

        expect(results).to be_empty
      end
    end
  end
end
