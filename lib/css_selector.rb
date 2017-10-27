class CssSelector
  def self.selectors
    {
      grid_subsection: '.child-topics-list',
      grid_taxon_links: '.child-topics-list ol li a',
      accordion_content_item_links: '.app-c-accordion__panel ol li a',
      accordion_subsection: '.app-c-accordion__section',
      accordion_subsection_title: '.app-c-accordion__title',
      leaf_content_item_links: '.app-c-taxon-list__link',
      leaf_subsection: '.app-c-taxon-list__item',
      blue_box_links: '.high-volume li a',
    }
  end

  def self.for(element)
    CssSelector.selectors[element]
  end
end
