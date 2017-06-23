require 'uri'
require 'google_drive'
require 'json'
require 'set'
require 'gds_api/rummager'

namespace :analyse do
  desc <<-DESC
    Return analysis of links present on new navigation pages. This will output any content item links for
    accordions and leaf pages; and both the taxon links and content item links for grids.
  DESC
  task :links, [:drive_folder] do |_task, args|
    analyser = Analysers::TaxonomyAnalyser.new('/education')

    results = analyser.analyse([
      Analysers::Taxons::AccordionLinkAnalyser.new,
      Analysers::Taxons::GridAndLeafLinkAnalyser.new,
    ])

    puts 'Saving to Google Drive...'

    href_to_path!(results)

    google_drive = GoogleDrive::Session.from_service_account_key('govuk-tagging-monitor-2f614b9b92c2.json')
    spreadsheet = create_spreadsheet(google_drive)
    set_spreadsheet_permissions(spreadsheet)

    write_summary_worksheet(results, spreadsheet)
    write_overview_worksheet(results, spreadsheet)
    write_page_type_worksheets(results, spreadsheet)
    write_taxon_worksheet(results, spreadsheet)
    write_whitehall_worksheet(results, spreadsheet)

    remove_empty_first_sheet(spreadsheet)

    target_folder = args[:drive_folder]
    save_spreadsheet(spreadsheet, google_drive, target_folder)

    puts '=== DONE ==='
    puts "Results saved to:"
    puts "#{spreadsheet.human_url}"

    post_url_to_slack(spreadsheet.human_url)
  end

  def href_to_path!(results)
    results.map! do |result|
      uri = URI(result[:link_href])
      result.merge(link_href: uri.path)
    end
  end

  def create_spreadsheet(google_drive)
    puts 'Create spreadsheet'
    date = Time.now.strftime('%Y-%m-%d')
    google_drive.create_spreadsheet("nav-page-inventory-#{date}")
  end

  def set_spreadsheet_permissions(spreadsheet)
    spreadsheet.acl.push(
      type: 'domain',
      domain: 'digital.cabinet-office.gov.uk',
      role: 'writer',
    )
  end

  def write_summary_worksheet(results, spreadsheet)
    puts('Write Summary worksheet')

    results_by_taxon = group_results(results, :navigation_url)
    results_by_navigation_page_type = group_results(results, :navigation_page_type)

    grid_results_by_taxon = group_results(
      results_by_navigation_page_type['grid'],
      :navigation_url
    )
    accordion_results_by_taxon = group_results(
      results_by_navigation_page_type['accordion'],
      :navigation_url
    )
    leaf_results_by_taxon = group_results(
      results_by_navigation_page_type['leaf'],
      :navigation_url
    )

    number_of_content_items = content_item_results(results).count
    number_of_whitehall_content_items = whitehall_content_item_results(results).count

    worksheet = spreadsheet.add_worksheet('Summary')
    add_rows(
      data: [
        ['Total Navigation pages', results_by_taxon.count],
        ['Total Grid pages', grid_results_by_taxon.count],
        ['Total Accordion pages', accordion_results_by_taxon.count],
        ['Total Leaf pages', leaf_results_by_taxon.count],
        ['Total unique & visible content items', number_of_content_items],
        ['Total unique & visible Whitehall content items', number_of_whitehall_content_items],
        ['Total unique & visible Non-Whitehall content items', number_of_content_items - number_of_whitehall_content_items],
        ['Total unique & visible hrefs', results.map { |r| r[:link_href] }.to_set.count],
        ['Total content items tagged', number_of_content_items_tagged_to_education]
      ],
      start_row_number: 1,
      worksheet: worksheet,
    )

    worksheet.save
  end

  def content_item_results(results)
    results.reject { |result| result[:section] == 'grid' }
  end

  def whitehall_content_item_results(results)
    results.select { |result| result[:publishing_app] == 'whitehall' }
  end

  def number_of_content_items_tagged_to_education
    rummager = GdsApi::Rummager.new('https://www.gov.uk/api')
    rummager.search(
      filter_part_of_taxonomy_tree: 'c58fdadd-7743-46d6-9629-90bb3ccc4ef0',
      count: 0
    ).to_h['total']
  end

  def write_overview_worksheet(results, spreadsheet)
    puts 'Write overview worksheet'
    worksheet = spreadsheet.add_worksheet('All pages')
    add_results_to_worksheet(results, worksheet, column_names)
  end

  def write_page_type_worksheets(results, spreadsheet)
    puts 'Write page type worksheets'
    results_by_page_type = group_results(results, :navigation_page_type)
    results_by_page_type.each_pair do |navigation_page_type, page_type_results|
      worksheet = spreadsheet.add_worksheet(navigation_page_type.capitalize)
      column_names = columns_to_display_for_navigation_page_type(navigation_page_type)
      add_results_to_worksheet(page_type_results, worksheet, column_names)
    end
  end

  def write_taxon_worksheet(results, spreadsheet)
    puts 'Write taxon worksheet'
    worksheet = spreadsheet.add_worksheet('Taxons')

    add_row(
      data: human_friendly(%w[navigation_page_type navigation_url section number_of_hrefs content_regex]),
      row_number: 1,
      worksheet: worksheet,
    )

    row_number = 1

    results_by_navigation_page_type = group_results(results, :navigation_page_type)

    results_by_navigation_page_type.each_pair do |navigation_page_type, page_type_results|

      results_by_navigation_url = group_results(page_type_results, :navigation_url)

      results_by_navigation_url.each_pair do |navigation_url, navigation_url_results|

        if navigation_page_type != 'leaf'
          navigation_url_results += navigation_url_results.map do |result|
            result.merge(section: 'all')
          end
        end

        results_by_section = group_results(navigation_url_results, :section)

        results_by_section.each_pair do |section, results|
          add_row(
            data: [navigation_page_type, navigation_url, section, results.count, regex_from_results(results)],
            row_number: row_number += 1,
            worksheet: worksheet,
          )
        end
      end
    end

    worksheet.save
  end

  def write_whitehall_worksheet(results, spreadsheet)
    puts 'Write Whitehall worksheet'
    worksheet = spreadsheet.add_worksheet('Whitehall')

    whitehall_results = whitehall_content_item_results(results)
    add_results_to_worksheet(whitehall_results, worksheet, [:link_href])
  end

  def save_spreadsheet(spreadsheet, google_drive, target_folder)
    return unless target_folder

    puts 'Save spreadsheet to Google Drive folder:'
    puts target_folder
    folder = google_drive.collection_by_url(target_folder)
    folder.add(spreadsheet)
  end

  def remove_empty_first_sheet(spreadsheet)
    spreadsheet.worksheets[0].delete
  end

  def group_results(results, grouping_column)
    results.reduce(Hash.new { |k, v| k[v] = [] }) do |hash, result|
      hash[result[grouping_column]] << result
      hash
    end
  end

  def regex_from_results(results)
    '^(' +
      results
        .map { |result| Regexp.escape(result[:link_href]) }
        .join('|') +
      ')$'
  end

  def column_names
    %i[
      navigation_page_type
      navigation_url
      total_number_of_links
      section
      total_number_of_links_per_section
      link_href
      number_of_tags
      navigation_urls
    ]
  end

  def columns_to_display_for_navigation_page_type(navigation_page_type)
    if navigation_page_type == 'accordion'
      column_names
    else
      column_names.reject { |column| column == :total_number_of_links_per_section }
    end
  end

  def add_results_to_worksheet(results, worksheet, columns_to_display)
    add_row(
      data: human_friendly(columns_to_display),
      row_number: 1,
      worksheet: worksheet,
    )

    add_rows(
      data: results_as_arrays(results, columns_to_display),
      start_row_number: 2,
      worksheet: worksheet,
    )

    worksheet.save
  end

  def add_row(data:, row_number:, worksheet:)
    data.each_with_index do |datum, column_number|
      worksheet[row_number, column_number + 1] = datum
    end
  end

  def add_rows(data:, start_row_number:, worksheet:)
    data.each_with_index do |row_data, row_increment|
      add_row(
        data: row_data,
        row_number: start_row_number + row_increment,
        worksheet: worksheet,
      )
    end
  end

  def results_as_arrays(results, columns_to_display)
    results.map do |result|
      columns_to_display.map { |column| result[column] }
    end
  end

  def human_friendly(headers)
    headers.map { |header| header.to_s.tr('_', ' ').capitalize }
  end

  def post_url_to_slack(url)
    Notifiers::Slack.notify(
      text: "Navigation link audit has been published here: #{url}",
    )
  end
end
