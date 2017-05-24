require 'uri'
require 'google_drive'

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

    puts 'Saving to Google Drive...'

    remove_host_from_href!(results)

    results_by_page_type = results.reduce(Hash.new { |k, v| k[v] = [] }) do |hash, result|
      hash[result[:navigation_page_type]] << result
      hash
    end

    google_drive = GoogleDrive::Session.from_service_account_key('govuk-tagging-monitor-2f614b9b92c2.json')

    date = Time.now.strftime('%Y-%m-%d')
    spreadsheet = google_drive.create_spreadsheet("nav-page-inventory-#{date}")
    overview_worksheet = spreadsheet.worksheets[0]
    overview_worksheet.title = 'Overview'

    add_results_to_worksheet(results, overview_worksheet)

    results_by_page_type.each_pair do |navigation_page_type, page_type_results|
      worksheet = spreadsheet.add_worksheet(navigation_page_type.capitalize)
      add_results_to_worksheet(page_type_results, worksheet)
    end

    folder = google_drive.collection_by_url('https://drive.google.com/drive/folders/0B6ekrNZ58HKUc3BqT3NoblRfOUE')
    folder.add(spreadsheet)

    puts '=== DONE ==='
    puts "Results saved to: #{spreadsheet.human_url}"
  end

  def remove_host_from_href!(results)
    results.map! do |result|
      uri = URI(result[:link_href])
      result.merge(link_href: uri.path)
    end
  end

  def result_columns
    %i[
      navigation_page_type
      taxon_base_path
      section
      link_href
    ].freeze
  end

  def add_results_to_worksheet(results, worksheet)
    headers = result_columns.map { |column| column.to_s.tr('_', ' ').capitalize }

    worksheet.insert_rows(1, [headers])
    worksheet.insert_rows(2, results_as_arrays(results))
    worksheet.save
  end

  def results_as_arrays(results)
    results.map do |result|
      result_columns.map { |column| result[column] }
    end
  end
end
