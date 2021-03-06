require 'webmock'

class BodyHtml
  def self.with_accordion_content_items(number_of_sections:, number_of_content_items:, number_of_blue_box_links: 5)
    html_string = ''

    if number_of_blue_box_links > 0
      html_string += '
        <div class="high-volume">
          <h2>Most viewed in this topic</h2>
          <ol>'

      number_of_blue_box_links.times do |blue_box_link_index|
        html_string += "<li>
           <a href='/blue-box-base-path-#{blue_box_link_index}'>
             Blue box content item #{blue_box_link_index}
           </a>
         </li>"
      end

      html_string += '</ol></div>'
    end

    number_of_sections.times do |section_index|
      html_string +=
        "<div class='topic-content'>
           <div class='app-c-accordion__section'>
             <div class='app-c-accordion__header'>
               <h2 class='app-c-accordion__title'>
                 Subsection #{section_index}
               </h2>
             </div>
             <div class='app-c-accordion__panel'>
               <ol>"

      number_of_content_items.times do |content_item_index|
        base_path = "/path-#{section_index}-#{content_item_index}"

        content_item = {
          'links' => {
            'taxons' => [ 'base_path' => "taxon-#{section_index}" ]
          },
          'publishing_app' => 'publishing_app',
        }.to_json

        WebMock.stub_request(:get, "https://www.gov.uk/api/content#{base_path}").
          to_return(body: content_item)

        html_string +=
          "<li>
            <a href='#{base_path}'>
              Content Item #{section_index}-#{content_item_index}
            </a>
          </li>"
      end

      html_string +=
        "</ol>
          </div>
        </div>
      </div>"
    end

    Nokogiri::HTML(html_string)
  end

  def self.with_grid_content_items(number_of_taxons:, number_of_content_items:)
    html_string =
      "<nav role='navigation' class='child-topics-list'>
        <ol>"

    number_of_taxons.times do |taxon_index|
      html_string +=
        "<li>
          <h2>
            <a href='/taxon-#{taxon_index}'>
              Taxon #{taxon_index}
            </a>
          </h2>
        </li>"
    end

    html_string +=
        "</ol>
      </nav>"

    html_string +=
      "<div class='app-c-taxon-list__item'>
        <div class='topic-content'>
          <ol>"

    number_of_content_items.times do |content_item_index|
      base_path = "/content-item-#{content_item_index}"
      content_item = {
        'links' => {
          'taxons' => [ 'base_path' => "taxon-#{content_item_index}" ]
        },
        'publishing_app' => 'publishing_app',
      }.to_json

      WebMock.stub_request(:get, "https://www.gov.uk/api/content#{base_path}").
        to_return(body: content_item)

      html_string +=
        "<li>
          <a class='app-c-taxon-list__link' href='#{base_path}'>
            Content Item #{content_item_index}
          </a>
        </li>"
    end

    html_string +=
        "</ol>
      </div>"

    Nokogiri::HTML(html_string)
  end

  def self.with_content_items(number_of_content_items:)
    with_grid_content_items(number_of_taxons: 0, number_of_content_items: number_of_content_items)
  end
end
