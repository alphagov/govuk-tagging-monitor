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
