# frozen_string_literal: true

require 'commonmarker'
require 'yaml'

module SSG
  class PageProcessor
    def self.process_all
      pages = {}
      Dir.glob("#{SSG::PAGES_DIR}/**/*.md") do |page_file|
        page_path = page_file.sub("#{PAGES_DIR}/", '').sub('.md', '')
        pages[page_path] = process_page(page_file)
      end
      pages
    end

    def self.process_page(page_file)
      page_content = File.read(page_file)
      parsed_content = Commonmarker.parse(
        page_content,
        options: { extension: { front_matter_delimiter: '---' } }
      )

      # TODO: Handle missing front matter
      front_matter = parsed_content.first
      page_config = YAML.safe_load(front_matter.to_commonmark).transform_keys(&:to_sym)

      {
        config: page_config,
        content: parsed_content.to_html
      }
    end
  end
end
