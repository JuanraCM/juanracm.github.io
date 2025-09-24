# frozen_string_literal: true

require 'fileutils'
require_relative 'layout_loader'
require_relative 'page_processor'
require_relative 'page_renderer'
require_relative 'asset_copier'

module SSG
  ROOT_DIR    = File.expand_path('..', __dir__)
  LAYOUTS_DIR = File.join(ROOT_DIR, 'layouts')
  PAGES_DIR   = File.join(ROOT_DIR, 'pages')
  ASSETS_DIR  = File.join(ROOT_DIR, 'assets')
  BUILD_DIR   = File.join(ROOT_DIR, 'build')

  def self.build
    prepare_output_dir

    layouts = LayoutLoader.load_all
    pages = PageProcessor.process_all

    renderer = PageRenderer.new(layouts)
    renderer.render_all(pages)

    AssetCopier.copy_assets
  end

  def self.prepare_output_dir
    FileUtils.rm_rf(BUILD_DIR)
    FileUtils.mkdir_p(BUILD_DIR)
  end
end
