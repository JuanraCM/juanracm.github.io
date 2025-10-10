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

        front_matter_text = front_matter.to_commonmark
        page_config = YAML.safe_load(front_matter_text, permitted_classes: [Date])
                          .transform_keys(&:to_sym)
        page_config[:reading_time] = calculate_reading_time(parsed_content, front_matter_text)

        {
          config: page_config,
          content: parsed_content.to_html
        }
      end

      private

      def calculate_reading_time(parsed_content, front_matter_text)
        raw_text = parsed_content.to_commonmark.sub(front_matter_text, '')
        words = raw_text.split.size

        reading_time_minutes = (words / 200.0).ceil

        "#{reading_time_minutes} minute#{'s' if reading_time_minutes > 1} read"
      end

      def raise_missing_front_matter_error(file)
        raise MissingFrontMatterError, "Missing front matter in #{file}"
      end
    end
  end
end
