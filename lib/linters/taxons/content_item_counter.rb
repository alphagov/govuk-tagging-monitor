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
        subsections = taxon.body_html.css(CssSelector.for(:accordion_subsection))
        subsections.map do |subsection|
          {
            title: subsection.css(CssSelector.for(:accordion_subsection_title)).text.strip,
            number_of_items: subsection.css(CssSelector.for(:accordion_content_item_links)).count,
          }
        end
      end

      # Returns the number of content items tagged to a taxon.
      # Grid pages: number of content items tagged beneath the grid
      # Accordion pages: number of content items tagged to the first accordion subsection
      # Leaf pages: number of all its content items
      def self.tagged_to_taxon(taxon)
        if taxon.is_accordion?
          subsections = ContentItemCounter.accordion(taxon)
          subsections.empty? ? 0 : subsections.first[:number_of_items]
        else
          ContentItemCounter.tagged_to_leaf(taxon)
        end
      end

      # Returns the number of content items tagged to a leaf or beneath a grid
      def self.tagged_to_leaf(taxon)
        taxon.body_html.css(CssSelector.for(:leaf_content_item_links)).count
      end

      # Returns the number of links in a blue box
      def self.blue_box_links(taxon)
        taxon.body_html.css(CssSelector.for(:blue_box_links)).count
      end
    end
  end
end
