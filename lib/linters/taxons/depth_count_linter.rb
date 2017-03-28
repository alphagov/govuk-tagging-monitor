module Linters
  module Taxons
    class DepthCountLinter < CountLinter
      def initialize(depth, &block)
        @depth = depth
        super(&block)
      end

      def self.at_depth(depth, &block)
        DepthCountLinter.new(depth, &block)
      end

      def lint(taxon)
        return [] unless taxon.depth == @depth

        number_of_content_items = ContentItemCounter.tagged_to_taxon(taxon)

        if @warn_if_count_evaluates_true.call(number_of_content_items)
          ["#{number_of_content_items} content items tagged"]
        else
          []
        end
      end
    end
  end
end