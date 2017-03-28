Taxon = Struct.new('Taxon', :base_path, :depth, :child_taxons, :body_html) do
  def initialize(*)
    super
    self.child_taxons ||= []
  end

  def has_grandchildren?
    child_taxons.any? { |child_taxon| child_taxon.child_taxons.any? }
  end

  def does_not_have_grandchildren?
    !has_grandchildren?
  end
end
