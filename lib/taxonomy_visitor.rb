class TaxonomyVisitor
  attr_reader :root_taxon_base_path

  def initialize(root_taxon_base_path)
    @root_taxon_base_path = root_taxon_base_path
  end

  def self.from_root_taxon_base_path(root_taxon_base_path)
    new(root_taxon_base_path)
  end

  # Visits the entire taxonomy from the given root taxon. Accepts a block,
  # which is called passing in each taxon as an argument.
  # Returns an array of the non-empty results of the block called for each taxon
  def visit_taxonomy(&block)
    visit_taxon_and_descendants(root_taxon, &block)
  end

  def size
    return @size unless @size.nil?

    count = 0
    queue = [root_taxon]

    until queue.empty?
      taxon = queue.shift
      count += 1
      taxon.child_taxons.each {|child_taxon| queue << child_taxon}
    end

    @size = count
  end

  private

  def visit_taxon_and_descendants(taxon, &block)
    results = Array(block.call(taxon))
    results += taxon.child_taxons.map do |child_taxon|
      visit_taxon_and_descendants(child_taxon, &block)
    end
    results.flatten
  end

  def root_taxon
    return @root_taxon unless @root_taxon.nil?

    root_taxon_content_item = HTTP.get_json("https://www.gov.uk/api/content#{root_taxon_base_path}")

    @root_taxon = Taxon.new(
      root_taxon_content_item['base_path'],
      0,
      child_taxons_from_content_item(root_taxon_content_item, 1)
    )
  end

  def child_taxons_from_content_item(content_item, depth)
    child_taxons = content_item.dig('links', 'child_taxons').to_a

    child_taxons.map do |child_taxon|
      Taxon.new(
        child_taxon['base_path'],
        depth,
        child_taxons_from_content_item(child_taxon, depth + 1)
      )
    end
  end
end
