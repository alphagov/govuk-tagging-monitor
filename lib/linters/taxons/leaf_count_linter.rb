module Linters
  module Taxons
    class LeafCountLinter < CountLinter
      def lint(taxon)
        return [] unless is_leaf?(taxon)

        number_of_content_items = taxon.body_html
          .css('.topic-content ol li a').count

        if @warn_if_count_evaluates_true.call(number_of_content_items)
          ["#{number_of_content_items} content items tagged"]
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
