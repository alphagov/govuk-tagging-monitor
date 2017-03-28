module Linters
  module Taxons
    class ContentItemCounter
      # Returns an array of objects containing information about each accordion subsection
      # of the form:
      # {
      #   title: 'string',    # title of the subsection
      #   number_of_items: 0  # number of content items in the subsection
      # }
      def self.accordion(taxon)
        subsections = taxon.body_html.css('.topic-content .subsection')
        subsections.map do |subsection|
          {
            title: subsection.css('.subsection-title').text,
            number_of_items: subsection.css('.subsection-content ol li a').count,
          }
        end
      end

      # Returns the number of content items tagged to a taxon. For a leaf page, this is
      # all of its content items. For a grid, this is the items tagged beneath the grid.
      # This should return 0 for an accordion (where content tagged to the taxon is hidden
      # in the accordion itself).
      def self.tagged_to_taxon(taxon)
        taxon.body_html.css('.topic-content ol li a').count
      end
    end
  end
end
