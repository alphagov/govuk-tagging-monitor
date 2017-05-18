require 'spec_helper'

RSpec.describe TaxonomyVisitor, '#visit_taxonomy' do
  context 'visiting a taxonomy with 3 levels' do
    before(:each) do
      stub_request(:get, 'https://www.gov.uk/api/content/root_taxon')
        .to_return(body: three_level_taxonomy.to_json)

      stub_request(:get, %r(https://www\.gov\.uk/(?!api/)))
        .to_return(body: '')

      @taxonomy_visitor = TaxonomyVisitor.from_root_taxon_base_path('/root_taxon')
    end

    it 'visits each taxon' do
      visited_base_paths = @taxonomy_visitor.visit_taxonomy(&:base_path)

      expect(visited_base_paths).to contain_exactly(
        '/root_taxon',
        '/child_taxon_1',
        '/child_taxon_2',
        '/grandchild_taxon_1',
        '/grandchild_taxon_2',
        '/grandchild_taxon_3'
       )
    end

    it 'correctly reports depths' do
      visited_taxons_and_depths = @taxonomy_visitor.visit_taxonomy do |taxon|
        [{
          base_path: taxon.base_path,
          depth: taxon.depth,
        }]
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
end
