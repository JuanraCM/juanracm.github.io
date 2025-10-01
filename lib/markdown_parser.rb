# frozen_string_literal: true

require 'commonmarker'
require 'yaml'

require_relative 'config'

module SSG
  class MarkdownParser
    class MissingFrontMatterError < SSGError; end

    def self.parse(page_file)
      page_content = File.read(page_file)
      parsed_content = Commonmarker.parse(
        page_content,
        options: { extension: { front_matter_delimiter: '---' } }
      )

      front_matter = parsed_content.first
      unless front_matter&.type == :frontmatter
        raise MissingFrontMatterError, "Missing front matter in #{page_file}"
      end

      page_config = YAML.safe_load(front_matter.to_commonmark).transform_keys(&:to_sym)

      {
        config: page_config,
        content: parsed_content.to_html
      }
    end
  end
end
