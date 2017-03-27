require 'spec_helper'

RSpec.describe GovukTaggingMonitor::Linters::Taxonomy, '#lint' do
  context 'linting a taxonomy with 3 levels' do
    before(:each) do
      stub_request(:get, 'https://www.gov.uk/api/content/root_taxon')
        .to_return(body: three_level_taxonomy.to_json)
    end

    it 'lints each taxon' do
      linter_spy = LinterSpy.new
      taxonomy_linter = GovukTaggingMonitor::Linters::Taxonomy.new(linters: [linter_spy])

      taxonomy_linter.lint('/root_taxon')

      expect(linter_spy.visited_base_paths).to contain_exactly(
        '/root_taxon',
        '/child_taxon_1',
        '/child_taxon_2',
        '/grandchild_taxon_1',
        '/grandchild_taxon_2',
        '/grandchild_taxon_3'
       )
    end

    it 'correctly records depths' do
      linter_spy = LinterSpy.new
      taxonomy_linter = GovukTaggingMonitor::Linters::Taxonomy.new(linters: [linter_spy])

      taxonomy_linter.lint('/root_taxon')

      visited_taxons_and_depths = linter_spy.visited_taxons.map do |taxon|
        {
          base_path: taxon.base_path,
          depth: taxon.depth,
        }
      end

      expect(visited_taxons_and_depths).to contain_exactly(
        {
         base_path: '/root_taxon',
         depth: 0,
        },
        {
         base_path: '/child_taxon_1',
         depth: 1,
        },
        {
         base_path: '/child_taxon_2',
         depth: 1,
        },
        {
          base_path: '/grandchild_taxon_1',
          depth: 2,
        },
       {
         base_path: '/grandchild_taxon_2',
         depth: 2,
       },
       {
         base_path: '/grandchild_taxon_3',
         depth: 2,
       },
      )
    end

    it 'calls all linters' do
      linter_spy_1 = LinterSpy.new
      linter_spy_2 = LinterSpy.new
      linter_spy_3 = LinterSpy.new

      taxonomy_linter = GovukTaggingMonitor::Linters::Taxonomy.new(
        linters: [
          linter_spy_1,
          linter_spy_2,
          linter_spy_3,
        ]
      )

      taxonomy_linter.lint('/root_taxon')

      expect(linter_spy_1.visited_base_paths).to contain_exactly(
        '/root_taxon',
        '/child_taxon_1',
        '/child_taxon_2',
        '/grandchild_taxon_1',
        '/grandchild_taxon_2',
        '/grandchild_taxon_3'
      )

      expect(linter_spy_2.visited_base_paths).to eq(linter_spy_1.visited_base_paths)
      expect(linter_spy_3.visited_base_paths).to eq(linter_spy_1.visited_base_paths)
    end
  end

  context 'linting a simple taxonomy' do
    before(:each) do
      stub_request(:get, 'https://www.gov.uk/api/content/root_taxon')
        .to_return(body: simple_taxonomy.to_json)
    end

    it 'returns an array of taxons and their warnings' do
      linter = LinterSpy.new

      taxonomy_linter = GovukTaggingMonitor::Linters::Taxonomy.new(
        linters: [linter]
      )

      warnings_by_taxon = taxonomy_linter.lint('/root_taxon')

      expect(warnings_by_taxon).to eq(
        [
          {
            taxon: {
              base_path: '/root_taxon',
            },
            warnings_by_linter: [
              linter: 'LinterSpy',
              warnings: ['/root_taxon linted'],
            ],
          },
          {
            taxon: {
              base_path: '/child_taxon',
            },
            warnings_by_linter: [
              linter: 'LinterSpy',
              warnings: ['/child_taxon linted'],
            ],
          },
        ]
      )
    end
  end

  def three_level_taxonomy
    {
      'base_path' => '/root_taxon',
      'links' => {
        'child_taxons' => [
          {
            'base_path' => '/child_taxon_1',
            'links' => {
              'child_taxons' => [
                {
                  'base_path' => '/grandchild_taxon_1',
                  'links' => {},
                },
              ],
            },
          },
          {
            'base_path' => '/child_taxon_2',
            'links' => {
              'child_taxons' => [
                {
                  'base_path' => '/grandchild_taxon_2',
                  'links' => {},
                },
                {
                  'base_path' => '/grandchild_taxon_3',
                  'links' => {},
                },
              ],
            },
          },
        ],
      } ,
    }
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
    def lint(taxon)
      visited_taxons << taxon
      ["#{taxon.base_path} linted"]
    end

    def visited_taxons
      @visited_taxons ||= []
    end

    def visited_base_paths
      visited_taxons.map { |taxon| taxon.base_path }
    end
  end
end
