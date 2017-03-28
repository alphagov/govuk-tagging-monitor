module Linters
  module Taxons
    class ContentItemCounter
      def self.accordion(taxon)
        subsections = taxon.body_html.css('.topic-content .subsection')
        subsections.map do |subsection|
          {
            title: subsection.css('.subsection-title').text,
            number_of_items: subsection.css('.subsection-content ol li a').count,
          }
        end
      end

      def self.tagged_to_taxon(taxon)
        taxon.body_html.css('.topic-content ol li a').count
      end
    end
  end
end
