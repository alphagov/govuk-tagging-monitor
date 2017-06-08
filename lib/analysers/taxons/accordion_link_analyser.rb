module Analysers
  module Taxons
    class AccordionLinkAnalyser
      def analyse(taxon)
        return [] unless taxon.is_accordion?

        taxon.body_html.css(CssSelector.for(:accordion_content_item_links))
          .reduce([]) do |results, link|

          section = link.ancestors(CssSelector.for(:accordion_subsection))
            .at_css(CssSelector.for(:accordion_subsection_title))
            .text.strip

          section_links_total = link.ancestors(CssSelector.for(:accordion_subsection))
            .css(CssSelector.for(:accordion_content_item_links)).count

          link_href = link.attr('href')
          link_base_path = link_href.split('https://www.gov.uk').last

          content_item = HTTP.get_json(
            "https://www.gov.uk/api/content#{link_base_path}"
          )

          taxon_tags = content_item['links']['taxons']
          number_of_tags = taxon_tags.count
          taxon_base_paths = taxon_tags.map { |taxon| taxon['base_path'] }

          results << {
            taxon_base_path: taxon.base_path,
            link_href: link_href,
            total_number_of_links_per_section: section_links_total,
            navigation_page_type: taxon.navigation_page_type,
            section: section,
            number_of_tags: number_of_tags,
            taxon_base_paths: taxon_base_paths.join(';'),
          }
        end
      end
    end
  end
end
