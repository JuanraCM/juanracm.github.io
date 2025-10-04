# frozen_string_literal: true

require 'commonmarker'
require 'yaml'

require_relative 'config'

module SSG
  class MarkdownParser
    class MissingFrontMatterError < SSGError; end

    class << self
      def parse(page_file)
        page_content = File.read(page_file)
        parsed_content = Commonmarker.parse(
          page_content,
          options: { extension: { front_matter_delimiter: '---' } }
        )

        front_matter = parsed_content.first
        raise_missing_front_matter_error(page_file) unless front_matter&.type == :frontmatter

        page_config = YAML.safe_load(front_matter.to_commonmark, permitted_classes: [Date])
                          .transform_keys(&:to_sym)

        {
          config: page_config,
          content: parsed_content.to_html
        }
      end

      private

      def raise_missing_front_matter_error(file)
        raise MissingFrontMatterError, "Missing front matter in #{file}"
      end
    end
  end
end
