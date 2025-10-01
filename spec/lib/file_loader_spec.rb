# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/file_loader'
require_relative '../../lib/markdown_parser'

describe SSG::FileLoader do
  before do
    stub_const('SSG::LAYOUTS_DIR', fixture_path('layouts'))
    stub_const('SSG::PAGES_DIR', fixture_path('pages'))
  end

  describe '.load_layouts' do
    it 'loads all layout files from the layouts directory' do
      layouts = SSG::FileLoader.load_layouts

      expect(layouts).to be_a(Hash)
      expect(layouts).not_to be_empty

      layouts.each do |name, content|
        expect(name).to be_a(String)
        expect(content).to be_a(String)
        expect(content).not_to be_empty
      end
    end
  end

  describe '.load_pages' do
    before do
      allow(SSG::MarkdownParser).to receive(:parse).with(anything).exactly(4).times
    end

    it 'processes all markdown files in the pages directory', :aggregate_failures do
      pages = SSG::FileLoader.load_pages

      expect(pages).to be_a(Hash)
      expect(pages.keys.count).to eq(4)
    end
  end
end
