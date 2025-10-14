# frozen_string_literal: true

require 'spec_helper'

describe SSG::PageRenderer do
  subject(:renderer) { described_class.new(layouts) }

  before do
    stub_const('SSG::BUILD_DIR', '/tmp/build')
  end

  describe '#render_all' do
    before do
      allow(File).to receive(:write)
    end

    describe 'with valid layout and template' do
      let(:layouts) do
        {
          'default' => File.read(fixture_path('layouts/default.html.erb'))
        }
      end
      let(:pages) do
        {
          'index' => {
            config: { title: 'Home', layout: 'default' },
            content: '<h1>Welcome to the homepage</h1>'
          }
        }
      end

      it 'renders all pages using the specified layouts' do
        renderer.render_all(pages)

        expect(File).to have_received(:write).with(
          '/tmp/build/index.html',
          include('<title>Home</title>', '<h1>Welcome to the homepage</h1>')
        )
      end
    end

    describe 'with missing layout' do
      let(:layouts) { {} }
      let(:pages) do
        {
          'index' => {
            config: { title: 'Home' },
            content: '<h1>Welcome to the homepage</h1>'
          }
        }
      end

      it 'raises MissingLayoutError when layout is not specified' do
        expect do
          renderer.render_all(pages)
        end.to raise_error(SSG::PageRenderer::MissingLayoutError, /Layout not specified/)
      end
    end
  end
end
