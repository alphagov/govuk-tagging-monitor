require 'csv'

namespace :analyse do
  desc <<-DESC
    Return analysis of links present on new navigation pages. This will output any content item links for
    accordions and leaf pages; and both the taxon links and content item links for grids.
  DESC
  task :links do
    analyser = Analysers::TaxonomyAnalyser.new('/education')

    results = analyser.analyse([
      Analysers::Taxons::AccordionLinkAnalyser.new,
      Analysers::Taxons::GridAndLeafLinkAnalyser.new,
    ])

    puts [
      'Taxon base path',
      'Link href',
      'Navigation page type',
      'Section',
    ].to_csv

    results.each do |result|
      puts [
        result[:taxon_base_path],
        result[:link_href],
        result[:navigation_page_type],
        result[:section],
      ].to_csv
    end
  end
end
