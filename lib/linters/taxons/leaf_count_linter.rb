module Linters
  module Taxons
    class LeafCountLinter < CountLinter
      def lint(taxon)
        return [] unless is_leaf?(taxon)

        number_of_content_items = ContentItemCounter.tagged_to_taxon(taxon)

        if @warn_if_count_evaluates_true.call(number_of_content_items)
          warning = "#{number_of_content_items} content items tagged"
          warning += " (which is #{@predicate_summary})" unless @predicate_summary.nil?
          [warning]
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
