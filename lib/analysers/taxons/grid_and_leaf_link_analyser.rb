module Analysers
  module Taxons
    class GridAndLeafLinkAnalyser
      def analyse(taxon)
        return [] if taxon.is_accordion?

        grid_results(taxon) + leaf_results(taxon)
      end

      def grid_results(taxon)
        fetch_links(
          taxon: taxon,
          css_selector: CssSelector.for(:grid_taxon_links),
          section: 'grid',
        )
      end

      def leaf_results(taxon)
        fetch_links(
          taxon: taxon,
          css_selector: CssSelector.for(:leaf_content_item_links),
          section: 'leaf',
        )
      end

      def fetch_links(taxon:, css_selector:, section:)
        taxon.body_html.css(css_selector)
          .reduce([]) do |results, link|

          results << {
            taxon_base_path: taxon.base_path,
            link_href: link.attr('href'),
            navigation_page_type: taxon.navigation_page_type,
            section: section,
          }
        end
      end
    end
  end
end
