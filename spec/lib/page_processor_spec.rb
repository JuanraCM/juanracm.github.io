# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/page_processor'

describe SSG::PageProcessor do
  before do
    stub_const('SSG::PAGES_DIR', fixture_path('pages'))
  end

  describe '.process_all' do
    before do
      allow(SSG::PageProcessor).to receive(:process_page).with(anything).exactly(4).times
    end

    it 'processes all markdown files in the pages directory', :aggregate_failures do
      pages = SSG::PageProcessor.process_all

      expect(pages).to be_a(Hash)
      expect(pages.keys.count).to eq(4)
    end
  end

  describe '.process_page' do
    context 'with a valid file' do
      let(:sample_page) { fixture_path('pages/valid.md') }

      it 'processes a single markdown file and extracts front matter and content', :aggregate_failures do
        page_data = SSG::PageProcessor.process_page(sample_page)

        expect(page_data).to be_a(Hash)
        expect(page_data[:config]).to be_a(Hash)
        expect(page_data[:config][:title]).to eq('Test File')
        expect(page_data[:config][:layout]).to eq('default')
        expect(page_data[:content]).to be_a(String)
        expect(page_data[:content]).to include('<strong>bold text</strong>')
      end
    end

    context 'with a file missing front matter' do
      let(:invalid_page) { fixture_path('pages/missing_frontmatter.md') }

      it 'raises a MissingFrontMatterError' do
        expect {
          SSG::PageProcessor.process_page(invalid_page)
        }.to raise_error(SSG::PageProcessor::MissingFrontMatterError, /Missing front matter/)
      end
    end
  end
end
