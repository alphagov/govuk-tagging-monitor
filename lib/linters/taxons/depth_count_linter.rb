module Linters
  module Taxons
    class DepthCountLinter
      # Depth of the taxonomy at which this linter is supposed to operate.
      # depth == 0 # Operate on root taxon
      # depth == 1 # Operate on root taxon's children
      # etc.
      attr_accessor :depth
      attr_accessor :count_linter

      def initialize
        yield self

        if self.depth.nil? || self.count_linter.nil?
          raise <<-ERROR
            depth and count_linter must both be set using a constructor block, such as:

              #{self.class.name}.new do |d|
                d.depth = 0
                d.count_linter = Linters::Taxons::CountLinter.warn_if_equal_to(0)
              end
          ERROR
        end
      end

      def lint(taxon)
        return [] unless taxon.depth == depth

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