Taxon = Struct.new('Taxon', :base_path, :depth, :child_taxons, :body_html) do
  def has_grandchildren?
    child_taxons.any? { |child_taxon| child_taxon.child_taxons.any? }
  end
end
