class CssSelector
  def self.selectors
    {
      grid_taxon_links: '.child-topics-list ol li a',
      accordion_content_item_links: '.subsection-content ol li a',
      accordion_subsection: '.subsection',
      accordion_subsection_title: '.subsection-title',
      leaf_content_item_links: '.parent-topic-contents ol li a',
      leaf_subsection: '.parent-topic-contents',
      blue_box_links: '.high-volume li a',
    }
  end

  def self.for(element)
    CssSelector.selectors[element]
  end
end
