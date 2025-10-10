# frozen_string_literal: true

require 'spec_helper'

describe SSG::MarkdownParser do
  describe '.parse' do
    context 'with a valid file' do
      let(:sample_page) { fixture_path('pages/valid.md') }

      it 'processes a single markdown file and extracts front matter and content', :aggregate_failures do
        page_data = described_class.parse(sample_page)

        expect(page_data).to be_a(Hash)
        expect(page_data[:config][:title]).to eq('Test File')
        expect(page_data[:config][:reading_time]).to eq('1 minute read')
        expect(page_data[:content]).to include('<strong>bold text</strong>')
      end
    end

    context 'with a file missing front matter' do
      let(:invalid_page) { fixture_path('pages/missing_frontmatter.md') }

      it 'raises a MissingFrontMatterError' do
        expect do
          described_class.parse(invalid_page)
        end.to raise_error(SSG::MarkdownParser::MissingFrontMatterError, /Missing front matter/)
      end
    end
  end
end
