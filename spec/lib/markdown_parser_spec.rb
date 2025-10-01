# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/markdown_parser'

describe SSG::MarkdownParser do
  describe '.parse' do
    context 'with a valid file' do
      let(:sample_page) { fixture_path('pages/valid.md') }

      it 'processes a single markdown file and extracts front matter and content', :aggregate_failures do
        page_data = SSG::MarkdownParser.parse(sample_page)

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
          SSG::MarkdownParser.parse(invalid_page)
        }.to raise_error(SSG::MarkdownParser::MissingFrontMatterError, /Missing front matter/)
      end
    end
  end
end
