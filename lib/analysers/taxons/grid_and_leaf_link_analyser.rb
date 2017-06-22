module Analysers
  module Taxons
    class GridAndLeafLinkAnalyser
      def analyse(taxon)
        return [] if taxon.is_accordion?

        grid_results(taxon) + leaf_results(taxon)
      end

      def grid_results(taxon)
        taxon.body_html.css(CssSelector.for(:grid_taxon_links))
          .reduce([]) do |results, link|

          links_total = link.ancestors(CssSelector.for(:grid_subsection))
            .css(CssSelector.for(:grid_taxon_links)).count

          results << {
            navigation_url: taxon.base_path,
            link_href: link.attr('href'),
            total_number_of_links: links_total,
            navigation_page_type: taxon.navigation_page_type,
            section: 'grid',
            number_of_tags: 'N/A',
            navigation_urls: 'N/A',
          }
        end
      end

      def leaf_results(taxon)
        taxon.body_html.css(CssSelector.for(:leaf_content_item_links))
          .reduce([]) do |results, link|

          links_total = link.ancestors(CssSelector.for(:leaf_subsection))
            .css(CssSelector.for(:leaf_content_item_links)).count

          link_href = link.attr('href')
          link_base_path = link_href.split('https://www.gov.uk').last

          content_item = HTTP.get_json(
            "https://www.gov.uk/api/content#{link_base_path}"
          )

          taxon_tags = content_item['links']['taxons']
          number_of_tags = taxon_tags.count
          taxon_base_paths = taxon_tags.map { |taxon| taxon['base_path'] }

          results << {
            navigation_url: taxon.base_path,
            link_href: link.attr('href'),
            total_number_of_links: links_total,
            navigation_page_type: taxon.navigation_page_type,
            section: 'leaf',
            number_of_tags: number_of_tags,
            navigation_urls: taxon_base_paths.join(';'),
            publishing_app: content_item['publishing_app'],
          }
        end
      end
    end
  end
end
