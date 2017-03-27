module Linters
  class Taxonomy
    attr_reader :linters
    attr_reader :warnings

    # The constructor for this class expects an array of Linter objects. These objects
    # must have a #lint method, which accepts a Taxon and returns an array of warnings
    # about that taxon
    def initialize(linters: [])
      @linters = linters
      @warnings = []
    end

    # Visits the entire taxonomy including and under the given taxon base path.
    # At each taxon, each of the linters provided in TaxonomyLinter#initialize
    # will have its #lint method called on the taxon.
    # The return value is an array of taxons and their warnings in the following
    # structure:
    # {
    #   taxon: 'base_path',
    #   warnings_by_linter: [
    #     {
    #       linter: 'LinterClassName',
    #       warnings: [
    #         'warning'
    #       ]
    #     }
    #   ]
    # }
    def lint(root_taxon_base_path)
      lint_taxon_and_descendants(root_taxon(root_taxon_base_path))
    end

    private
    def lint_taxon_and_descendants(taxon)
      warnings = [lint_taxon(taxon)]
      warnings += taxon.child_taxons.map do |child_taxon|
        lint_taxon_and_descendants(child_taxon)
      end

      warnings.flatten
    end

    def lint_taxon(taxon)
      taxon = taxon.clone
      taxon.body_html = Nokogiri::HTML(
        HTTP.get("https://www.gov.uk#{taxon.base_path}"))

      warnings_by_linter = linters.map do |linter|
        {
          linter: linter.class.name,
          warnings: linter.lint(taxon),
        }
      end

      {
        taxon: {
          base_path: taxon.base_path,
        },
        warnings_by_linter: warnings_by_linter,
      }
    end

    def root_taxon(root_taxon_base_path)
      root_taxon_content_item = HTTP.get_json("https://www.gov.uk/api/content#{root_taxon_base_path}")

      Taxon.new(
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
end
