RSpec.describe Linters::TaxonomyLinter, '#lint' do
  context 'linting a simple taxonomy' do
    before(:each) do
      stub_request(:get, 'https://www.gov.uk/api/content/root_taxon')
        .to_return(body: simple_taxonomy.to_json)

      stub_request(:get, %r(https://www\.gov\.uk/(?!api/)))
        .to_return(body: '')

      @taxonomy_linter = Linters::TaxonomyLinter.from_root_taxon_base_path('/root_taxon')
    end

    context 'with a linter that warns for every taxon' do
      before(:each) do
        @linter = LinterSpy.new { |base_path| "#{base_path} linted" }
      end

      it 'returns an array of taxons and their warnings' do
        warnings_by_taxon = @taxonomy_linter.lint([@linter])

        expect(warnings_by_taxon).to eq(
          [
            '/root_taxon: /root_taxon linted',
            '/child_taxon: /child_taxon linted',
          ]
        )
      end
    end

    context 'with a linter that warns for no taxons' do
      before(:each) do
        @linter = LinterSpy.new
      end

      it 'returns an array of taxons and their warnings' do
        warnings_by_taxon = @taxonomy_linter.lint([@linter])

        expect(warnings_by_taxon).to eq(
          []
        )
      end
    end

    it 'calls all linters' do
      linter_spy_1 = LinterSpy.new
      linter_spy_2 = LinterSpy.new
      linter_spy_3 = LinterSpy.new

      @taxonomy_linter.lint([
        linter_spy_1,
        linter_spy_2,
        linter_spy_3
      ])

      expect(linter_spy_1.visited_base_paths).to contain_exactly(
        '/child_taxon',
        '/root_taxon',
      )

      expect(linter_spy_2.visited_base_paths).to eq(linter_spy_1.visited_base_paths)
      expect(linter_spy_3.visited_base_paths).to eq(linter_spy_1.visited_base_paths)
    end
  end

  def simple_taxonomy
    {
      'base_path' => '/root_taxon',
      'links' => {
        'child_taxons' => [
          'base_path' => '/child_taxon',
          'links' => {},
        ],
      },
    }
  end

  class LinterSpy
    def initialize(&block)
      @warning = block
    end

    def lint(taxon)
      visited_taxons << taxon
      if @warning.nil?
        []
      else
        [@warning.call(taxon.base_path)]
      end
    end

    def visited_taxons
      @visited_taxons ||= []
    end

    def visited_base_paths
      visited_taxons.map { |taxon| taxon.base_path }
    end

    def name
      self.class.name
    end
  end
end
