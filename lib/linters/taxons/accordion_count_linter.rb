module Linters
  module Taxons
    class AccordionCountLinter
      def lint(taxon)
        return [] unless is_accordion?(taxon)

        subsections = taxon.body_html.css('.topic-content .subsection')
        subsections.each_with_object([]) do |subsection, warnings|
          number_of_content_items = subsection.css('.subsection-content ol li a').count

          # AKG TODO: Move these numbers into a config?
          if number_of_content_items == 0 || number_of_content_items > 20
            subsection_title = subsection.css('.subsection-title').text
            warnings << "Accordion subsection '#{subsection_title}' has #{number_of_content_items} content items tagged"
          end
        end
      end

      def is_accordion?(taxon)
        taxon.child_taxons.any? && taxon.does_not_have_grandchildren?
      end
    end
  end
end
