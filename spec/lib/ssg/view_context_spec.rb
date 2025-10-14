# frozen_string_literal: true

require 'spec_helper'

describe SSG::ViewContext do
  subject(:view_context) { described_class.new(layouts, page_data) }

  let(:layouts) do
    {
      'base' => File.read(fixture_path('layouts/base.html.erb')),
      'default' => File.read(fixture_path('layouts/default.html.erb')),
      'home' => File.read(fixture_path('layouts/home.html.erb'))
    }
  end
  let(:page_data) do
    {
      config: {
        layout: 'home',
        title: 'Test Page'
      },
      content: '<p>This is a test page</p>'
    }
  end

  describe '#render' do
    subject(:rendered_output) { view_context.render }

    context 'when a parent layout is specified' do
      it 'includes content from the parent layout' do
        expect(rendered_output).to include('<title>Test Page</title>')
      end

      it 'includes content from the page layout' do
        expect(rendered_output).to include('<h1>Welcome to Our Website</h1>')
      end

      it 'includes page content' do
        expect(rendered_output).to include('<p>This is a test page</p>')
      end
    end

    context 'when a parent layout is not specified' do
      before do
        page_data[:config][:layout] = 'default'
      end

      it 'includes content from the page layout' do
        expect(rendered_output).to include('<h1>This is the default layout</h1>')
      end

      it 'includes page content' do
        expect(rendered_output).to include('<p>This is a test page</p>')
      end
    end

    context 'when an invalid layout key is provided' do
      before do
        page_data[:config][:layout] = 'nonexistent_layout'
      end

      it 'raises an InvalidLayoutError' do
        expect { rendered_output }.to raise_error(SSG::ViewContext::InvalidLayoutError)
      end
    end
  end
end
