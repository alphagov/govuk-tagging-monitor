module Linters
  module Taxons
    class LeafCountLinter
      def lint(taxon)
        return [] unless is_leaf?(taxon)

        number_of_content_items_displayed = taxon.body_html
          .css('.topic-content ol li a').count

        # AKG TODO: move these numbers into a config?
        if number_of_content_items_displayed == 0 || number_of_content_items_displayed > 20
          ["#{number_of_content_items_displayed} content items tagged"]
        else
          []
        end
      end

      def is_leaf?(taxon)
         taxon.child_taxons.empty?
      end
    end
  end
end
