module Linters
  module Taxons
    class LeafCountLinter < CountLinter
      def lint(taxon)
        return [] unless taxon.is_leaf?

        number_of_content_items = ContentItemCounter.tagged_to_leaf(taxon)

        if @warn_if_count_evaluates_true.call(number_of_content_items)
          warning = "#{number_of_content_items} content items tagged"
          warning += " (which is #{@predicate_summary})" unless @predicate_summary.nil?
          [warning]
        else
          []
        end
      end
    end
  end
end
