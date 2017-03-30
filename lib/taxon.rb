Taxon = Struct.new('Taxon', :base_path, :depth, :child_taxons, :body_html) do
  def initialize(*)
    super
    self.child_taxons ||= []
  end

  def is_leaf?
    child_taxons.empty?
  end

  def is_accordion?
    child_taxons.any? && does_not_have_grandchildren?
  end

  def has_grandchildren?
    child_taxons.any? { |child_taxon| child_taxon.child_taxons.any? }
  end

  def does_not_have_grandchildren?
    !has_grandchildren?
  end
end
