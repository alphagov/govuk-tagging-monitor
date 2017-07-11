module Linters
  module Taxons
    class BlueBoxCountLinter < CountLinter
      def lint(taxon)
        return [] unless taxon.is_accordion?

        blue_box_links = ContentItemCounter.blue_box_links(taxon)

        return [] unless @warn_if_count_evaluates_true.call(blue_box_links)

        warning = "Blue box section has #{blue_box_links} links to content items"
        warning += " (which is #{@predicate_summary})" unless @predicate_summary.nil?

        [warning]
      end
    end
  end
end
