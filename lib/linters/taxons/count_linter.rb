module Linters
  module Taxons
    class CountLinter
      attr_reader :warn_if_count_evaluates_true
      attr_reader :predicate_summary

      def initialize(predicate_summary = nil, &block)
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
        @predicate_summary = predicate_summary
      end

      def self.warn_if_equal_to(number)
        self.new("==#{number}") { |count| count == number }
      end

      def self.warn_if_greater_than(number)
        self.new(">#{number}") { |count| count > number }
      end

      def self.warn_if_not_equal_to(number)
        self.new("!=#{number}") { |count| count != number }
      end

      def name
        n = self.class.name
        n += " #{@predicate_summary}" unless @predicate_summary.nil?
        n
      end
    end
  end
end
