module Linters
  module Taxons
    class DepthCountLinter
      attr_accessor :depth
      attr_accessor :count_linter

      def initialize
        yield self
        raise 'depth must be set' if self.depth.nil?
        raise 'count_linter must be set' if self.count_linter.nil?
      end

      def lint(taxon)
        return [] unless taxon.depth == @depth

        number_of_content_items = ContentItemCounter.tagged_to_taxon(taxon)

        if @count_linter.warn_if_count_evaluates_true.call(number_of_content_items)
          warning = "#{number_of_content_items} content items tagged"
          warning += " (which is #{@count_linter.predicate_summary})"
          [warning]
        else
          []
        end
      end

      def name
        n = self.class.name + " depth:#{@depth}"
        n += " #{@count_linter.predicate_summary}" unless @count_linter.predicate_summary.nil?
        n
      end
    end
  end
end