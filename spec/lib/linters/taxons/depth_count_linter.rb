require 'spec_helper'

RSpec.describe Linters::Taxons::DepthCountLinter, '#lint' do
  context 'linting a root taxon' do
    before(:each) do
      @taxon = Taxon.new(
        '/base-path',
        0,
        [],
      )
    end

    context 'with a linter checking for >0 content items at depth 0' do
      before(:each) do
        @linter = Linters::Taxons::DepthCountLinter.at_depth(0) { |count| count > 0 }
      end

      it 'warns for taxons with 1 content item' do
        @taxon.body_html = body_html_with_content_items(1)

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          '0 content items tagged'
        )

      end

      it 'does not warn for taxons with 0 content item' do
        @taxon.body_html = body_html_with_content_items(0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end

    context 'with a linter checking for >0 content items at depth 1' do
      before(:each) do
        @linter = Linters::Taxons::DepthCountLinter.at_depth(0) { |count| count > 0 }
      end

      it 'does not warn for taxons with 1 content item' do
        @taxon.body_html = body_html_with_content_items(1)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty

      end
    end
  end

  context 'linting a child taxon' do
    before(:each) do
      @taxon = Taxon.new(
        '/base-path',
        1,
        [],
      )
    end

    context 'with a linter checking for >0 content items at depth 1' do
      before(:each) do
        @linter = Linters::Taxons::DepthCountLinter.at_depth(1) { |count| count > 0 }
      end

      it 'warns for taxons with 1 content item' do
        @taxon.body_html = body_html_with_content_items(1)

        warnings = @linter.lint(@taxon)

        expect(warnings).to contain_exactly(
          '0 content items tagged'
        )

      end

      it 'does not warn for taxons with 0 content item' do
        @taxon.body_html = body_html_with_content_items(0)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty
      end
    end

    context 'with a linter checking for >0 content items at depth 0' do
      before(:each) do
        @linter = Linters::Taxons::DepthCountLinter.at_depth(0) { |count| count > 0 }
      end

      it 'does not warn for taxons with 1 content item' do
        @taxon.body_html = body_html_with_content_items(1)

        warnings = @linter.lint(@taxon)

        expect(warnings).to be_empty

      end
    end
  end

  def body_html_with_content_items(number_of_content_items)
    html_string = '<div class="topic-content"><ol>'

    number_of_content_items.times do
      html_string += '<li><a href>Content Item</a></li>'
    end

    html_string += '</ol></div>'

    Nokogiri::HTML(html_string)
  end
end