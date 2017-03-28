require 'colorize'

module Linters
  class Taxonomy
    attr_reader :root_taxon_base_path
    attr_reader :warnings

    # The constructor for this class expects an array of Linter objects. These objects
    # must have a #lint method, which accepts a Taxon and returns an array of warnings
    # about that taxon
    def initialize(root_taxon_base_path)
      @root_taxon_base_path = root_taxon_base_path
      @warnings = []
    end

    def self.from_root_taxon_base_path(root_taxon_base_path)
      Taxonomy.new(root_taxon_base_path)
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
    def lint(linters)
      lint_taxon_and_descendants(linters, root_taxon)
    end

    def size
      count = 0
      queue = [root_taxon]

      until queue.empty?
        taxon = queue.shift
        count += 1
        taxon.child_taxons.each { |child_taxon| queue << child_taxon }
      end

      count
    end

    private
    def lint_taxon_and_descendants(linters, taxon)
      warnings = [lint_taxon(linters, taxon)]
      warnings += taxon.child_taxons.map do |child_taxon|
        lint_taxon_and_descendants(linters, child_taxon)
      end

      warnings.flatten.reject { |warning| warning.nil? }
    end

    def lint_taxon(linters, taxon)
      puts "#{taxon.base_path}"

      taxon = taxon.clone
      taxon.body_html = Nokogiri::HTML(
        HTTP.get("https://www.gov.uk#{taxon.base_path}"))

      warnings_by_linter = linters.each_with_object([]) do |linter, linter_warnings|
        puts "  #{linter.name}"
        warnings = linter.lint(taxon)
        if warnings.any?
          warnings.each do |warning|
            puts "    #{warning}".red
          end
          linter_warnings << {
            linter: linter.name,
            warnings: linter.lint(taxon),
          }
        else
          puts "    OK".green
        end
      end

      if warnings_by_linter.any?
        {
          taxon: {
            base_path: taxon.base_path,
          },
          warnings_by_linter: warnings_by_linter,
        }
      end
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
end
