# frozen_string_literal: true

require 'spec_helper'

require 'fileutils'

describe SSG::AssetCopier do
  let(:assets_dir) { '/tmp/assets' }
  let(:build_dir) { '/tmp/build' }

  before do
    stub_const('SSG::ASSETS_DIR', assets_dir)
    stub_const('SSG::BUILD_DIR', build_dir)
  end

  describe '.copy_assets' do
    before do
      allow(FileUtils).to receive(:cp_r)

      described_class.copy_assets
    end

    it 'copies assets from ASSETS_DIR to BUILD_DIR' do
      expect(FileUtils).to have_received(:cp_r).with(assets_dir, build_dir)
    end
  end
end
