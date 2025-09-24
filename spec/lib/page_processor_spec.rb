# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/page_processor'

describe SSG::PageProcessor do
  before do
    stub_const('SSG::PAGES_DIR', fixture_path('pages'))
  end

  describe '.process_all' do
    it 'processes all markdown files in the pages directory' do
      pages = SSG::PageProcessor.process_all

      expect(pages).to be_a(Hash)
      expect(pages).not_to be_empty

      pages.each do |page_path, page_data|
        expect(page_path).to be_a(String)
        expect(page_data).to be_a(Hash)
        expect(page_data).to have_key(:config)
        expect(page_data).to have_key(:content)

        expect(page_data[:config]).to be_a(Hash)
        expect(page_data[:config]).not_to be_empty

        expect(page_data[:content]).to be_a(String)
        expect(page_data[:content]).not_to be_empty
      end
    end
  end

  describe '.process_page' do
    let(:sample_page) { fixture_path('pages/index.md') }

    it 'processes a single markdown file and extracts front matter and content' do
      page_data = SSG::PageProcessor.process_page(sample_page)

      expect(page_data).to be_a(Hash)
      expect(page_data).to have_key(:config)
      expect(page_data).to have_key(:content)

      expect(page_data[:config]).to be_a(Hash)
      expect(page_data[:config]).not_to be_empty
      expect(page_data[:config][:title]).to eq('Test File')
      expect(page_data[:config][:layout]).to eq('default')

      expect(page_data[:content]).to be_a(String)
      expect(page_data[:content]).to include('<strong>bold text</strong>')
    end
  end
end
