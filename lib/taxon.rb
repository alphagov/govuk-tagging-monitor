Taxon = Struct.new('Taxon', :base_path, :depth, :child_taxons) do
  def initialize(*)
    super
    self.child_taxons ||= []
  end

  def body_html=(body_html)
    @body_html = body_html
  end

  def body_html
    @body_html ||= Nokogiri::HTML(
      HTTP.get("https://www.gov.uk#{base_path}?ABTest-NavigationTest=ShowBlueBox")
    )
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

  def navigation_page_type
    if is_leaf?
      'leaf'
    elsif is_accordion?
      'accordion'
    else
      'grid'
    end
  end
end
