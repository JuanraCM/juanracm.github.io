# frozen_string_literal: true

require_relative 'config'
require_relative 'markdown_parser'

module SSG
  class FileLoader
    class AssetNotFoundError < SSGError; end

    class << self
      def load_layouts
        layouts = {}

        Dir.glob("#{LAYOUTS_DIR}/*.html.erb") do |layout_file|
          layout_name = File.basename(layout_file, '.html.erb')
          layouts[layout_name] = File.read(layout_file)
        end

        layouts
      end

      def load_pages
        pages = {}

        Dir.glob("#{PAGES_DIR}/**/*.md") do |page_file|
          page_path = page_file.sub("#{PAGES_DIR}/", '').sub('.md', '')
          pages[page_path] = SSG::MarkdownParser.parse(page_file)
        end

        pages
      end

      def load_asset(path)
        full_path = File.join(ASSETS_DIR, path)

        (File.exist?(full_path) && File.file?(full_path)) || raise_asset_not_found_error(path)

        File.read(full_path)
      end

      private

      def raise_asset_not_found_error(path)
        raise AssetNotFoundError, "Asset '#{path}' not found."
      end
    end
  end
end
