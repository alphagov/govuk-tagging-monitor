module Linters
  module Taxons
    class LeafCountLinter
      def lint(taxon)
        return [] if taxon.child_taxons.any?

        number_of_content_items_displayed = taxon.body_html
          .css('.topic-content ol li').size

        if number_of_content_items_displayed == 0 || number_of_content_items_displayed > 20
          ["#{number_of_content_items_displayed} content items tagged"]
        else
          []
        end
      end
    end
  end
end
