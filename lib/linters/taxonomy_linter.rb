require 'colorize'

module Linters
  class TaxonomyLinter < TaxonomyVisitor
    def lint(linters)
      visit_taxonomy do |taxon|
        puts taxon.base_path

        linters.each_with_object([]) do |linter, taxon_warnings|
          puts "  #{linter.name}"
          linter_warnings = linter.lint(taxon)

          if linter_warnings.any?
            linter_warnings.each do |warning|
              puts "    ✗ #{warning}".red
              taxon_warnings << "#{taxon.base_path}: #{warning}"
            end
          else
            puts "    ✓ OK".green
          end
        end
      end
    end
  end
end
