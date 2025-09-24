# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/page_renderer'

describe SSG::PageRenderer do
  subject(:renderer) { described_class.new(layouts) }

  before do
    stub_const('SSG::BUILD_DIR', '/tmp/build')
  end

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

  describe '#render_all' do
    before do
      allow(File).to receive(:write)
    end

    it 'renders all pages using the specified layouts' do
      renderer.render_all(pages)

      expect(File).to have_received(:write).with(
        '/tmp/build/index.html',
        include('<title>Home</title>', '<h1>Welcome to the homepage</h1>')
      )
    end
  end
end
