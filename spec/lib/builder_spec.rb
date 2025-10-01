# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/builder'

describe SSG::Builder do
  describe '.build' do
    let(:renderer) { instance_double(SSG::PageRenderer) }

    before do
      allow(FileUtils).to receive(:rm_rf).once
      allow(FileUtils).to receive(:mkdir_p).once
      allow(SSG::FileLoader).to receive(:load_layouts).and_return({}).once
      allow(SSG::FileLoader).to receive(:load_pages).and_return({}).once
      allow(SSG::PageRenderer).to receive(:new).and_return(renderer)
      allow(renderer).to receive(:render_all).once
      allow(SSG::AssetCopier).to receive(:copy_assets).once
    end

    describe 'successful build' do
      it 'builds successfully' do
        SSG::Builder.build
      end
    end

    describe 'build with error' do
      before do
        allow(SSG::FileLoader).to receive(:load_layouts)
          .and_raise(SSG::SSGError, 'Layout load error')
      end

      it 'handles errors gracefully' do
        expect {
          SSG::Builder.build
        }.not_to raise_error
      end
    end
  end
end
