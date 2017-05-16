module Analysers
  class TaxonomyAnalyser < TaxonomyVisitor
    def analyse(analysers)
      results = visit_taxonomy do |taxon|
        puts "Analysing #{taxon.base_path}..."

        analysers.each_with_object([]) do |analyser, analyser_results|
          results = analyser.analyse(taxon)
          next if results.empty?
          analyser_results << results
        end
      end

      results.flatten
    end
  end
end
