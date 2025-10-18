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

  before do
    stub_const('SSG::ASSETS_DIR', fixture_path('assets'))
  end

  describe '#render' do
    subject(:rendered_output) { view_context.render }

    let(:page) { Capybara::Node::Simple.new(rendered_output) }

    context 'when a parent layout is specified' do
      it 'includes content from the parent layout' do
        expect(page).to have_title('Test Page')
      end

      it 'includes content from the page layout' do
        expect(page).to have_css('h1', text: 'Welcome to Our Website')
      end

      it 'includes page content' do
        expect(page).to have_css('p', text: 'This is a test page')
      end

      it 'includes the page class in the body tag' do
        expect(page).to have_css('body.page--home')
      end

      it 'includes page content for the main container' do
        expect(page).to have_css('.main-container', text: 'This is the main container content.')
      end

      it 'includes footer content from the footer' do
        expect(page).to have_css('footer', text: 'This is the footer content.')
      end

      it 'includes an inline svg asset' do
        expect(page).to have_css('svg.site-logo')
      end
    end

    context 'when a parent layout is not specified' do
      before do
        page_data[:config][:layout] = 'default'
      end

      it 'includes content from the page layout' do
        expect(page).to have_css('h1', text: 'This is the default layout')
      end

      it 'includes page content' do
        expect(page).to have_css('p', text: 'This is a test page')
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
