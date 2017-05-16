RSpec.describe Analysers::TaxonomyAnalyser, '#analyse' do
  context 'analysing a simple taxonomy' do
    before(:each) do
      stub_request(:get, 'https://www.gov.uk/api/content/root_taxon')
        .to_return(body: simple_taxonomy.to_json)

      stub_request(:get, %r(https://www\.gov\.uk/(?!api/)))
        .to_return(body: '')

      @taxonomy_analyser = Analysers::TaxonomyAnalyser.from_root_taxon_base_path('/root_taxon')
    end

    context 'with an analyser that returns all taxon paths' do
      before(:each) do
        @analyser = AnalyserSpy.new(&:base_path)
      end

      it 'returns an array of base paths' do
        results = @taxonomy_analyser.analyse([@analyser])

        expect(results).to contain_exactly(
          '/root_taxon',
          '/child_taxon',
        )
      end
    end

    context 'with an analyser that never returns results' do
      before(:each) do
        @analyser = AnalyserSpy.new
      end

      it 'returns an empty array' do
        results = @taxonomy_analyser.analyse([@analyser])

        expect(results).to be_empty
      end
    end

    it 'calls all analysers' do
      analyser_spy_1 = AnalyserSpy.new
      analyser_spy_2 = AnalyserSpy.new
      analyser_spy_3 = AnalyserSpy.new

      @taxonomy_analyser.analyse([
        analyser_spy_1,
        analyser_spy_2,
        analyser_spy_3
      ])

      expect(analyser_spy_1.visited_base_paths).to contain_exactly(
        '/child_taxon',
        '/root_taxon',
      )

      expect(analyser_spy_2.visited_base_paths).to eq(analyser_spy_1.visited_base_paths)
      expect(analyser_spy_3.visited_base_paths).to eq(analyser_spy_1.visited_base_paths)
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

  class AnalyserSpy
    def initialize(&block)
      @analysis = block
    end

    def analyse(taxon)
      visited_taxons << taxon
      if @analysis.nil?
        []
      else
        [@analysis.call(taxon)]
      end
    end

    def visited_taxons
      @visited_taxons ||= []
    end

    def visited_base_paths
      visited_taxons.map(&:base_path)
    end

    def name
      self.class.name
    end
  end
end
