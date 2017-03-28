module Linters
  module Taxons
    class CountLinter
      def initialize(&block)
        if block.nil?
          raise <<-BLOCK
            Please initialize #{self.class.name} with a block. This block should be a
            predicate that evaluates the number of content items on the page.
            If this predicate evaluates to true, a warning will be logged.
  
            For example:
  
              #{self.class.name}.new { |count| count == 0 }
  
            will create a linter that will log warnings if 0 content items are tagged
          BLOCK
        end

        @warn_if_count_evaluates_true = block
      end
    end
  end
end