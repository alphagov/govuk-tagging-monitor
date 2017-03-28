module Linters
  module Taxons
    class AccordionCountLinter < CountLinter
      def lint(taxon)
        return [] unless is_accordion?(taxon)

        ContentItemCounter.accordion(taxon).each_with_object([]) do |subsection, warnings|
          if @warn_if_count_evaluates_true.call(subsection[:number_of_items])
            warnings << "Accordion subsection '#{subsection[:title]}' has #{subsection[:number_of_items]} content items tagged"
          end
        end
      end

      def is_accordion?(taxon)
        taxon.child_taxons.any? && taxon.does_not_have_grandchildren?
      end
    end
  end
end