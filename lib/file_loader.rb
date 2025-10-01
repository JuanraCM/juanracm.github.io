# frozen_string_literal: true

require_relative 'config'
require_relative 'markdown_parser'

module SSG
  class FileLoader
    def self.load_layouts
      layouts = {}

      Dir.glob("#{LAYOUTS_DIR}/*.html.erb") do |layout_file|
        layout_name = File.basename(layout_file, '.html.erb')
        layouts[layout_name] = File.read(layout_file)
      end

      layouts
    end

    def self.load_pages
      pages = {}

      Dir.glob("#{PAGES_DIR}/**/*.md") do |page_file|
        page_path = page_file.sub("#{PAGES_DIR}/", '').sub('.md', '')
        pages[page_path] = SSG::MarkdownParser.parse(page_file)
      end

      pages
    end
  end
end
