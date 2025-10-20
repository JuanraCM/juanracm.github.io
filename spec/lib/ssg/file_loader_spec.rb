# frozen_string_literal: true

require 'spec_helper'

describe SSG::FileLoader do
  before do
    stub_const('SSG::LAYOUTS_DIR', fixture_path('layouts'))
    stub_const('SSG::PAGES_DIR', fixture_path('pages'))
    stub_const('SSG::ASSETS_DIR', fixture_path('assets'))
  end

  describe '.load_layouts' do
    it 'loads all layout files from the layouts directory', :aggregate_failures do
      layouts = described_class.load_layouts

      expect(layouts).to be_a(Hash)

      first_key, first_value = layouts.first
      expect(first_key).to be_a(String)
      expect(first_value).to be_a(String)
    end
  end

  describe '.load_pages' do
    before do
      allow(SSG::MarkdownParser).to receive(:parse).with(anything).exactly(4).times
    end

    it 'processes all markdown files in the pages directory', :aggregate_failures do
      pages = described_class.load_pages

      expect(pages).to be_a(Hash)
      expect(pages.keys.count).to eq(4)
    end
  end

  describe '.load_asset' do
    context 'when the asset exists' do
      it 'loads the asset file content' do
        content = described_class.load_asset('icon.svg')

        expect(content).to include('<svg')
      end
    end

    context 'when the asset does not exist' do
      it 'raises AssetNotFoundError' do
        expect do
          described_class.load_asset('unknown_icon.png')
        end.to raise_error(SSG::FileLoader::AssetNotFoundError, /Asset 'unknown_icon.png' not found/)
      end
    end
  end
end
