# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/layout_loader'

describe SSG::LayoutLoader do
  before do
    stub_const('SSG::LAYOUTS_DIR', fixture_path('layouts'))
  end

  describe '.load_all' do
    it 'loads all layout files from the layouts directory' do
      layouts = SSG::LayoutLoader.load_all

      expect(layouts).to be_a(Hash)
      expect(layouts).not_to be_empty

      layouts.each do |name, content|
        expect(name).to be_a(String)
        expect(content).to be_a(String)
        expect(content).not_to be_empty
      end
    end
  end
end
