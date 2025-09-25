# frozen_string_literal: true

require 'erb'

require_relative 'config'

module SSG
  class PageRenderer
    def initialize(layouts)
      @layouts = layouts
    end

    def render_all(pages)
      pages.each do |page_path, page_data|
        render_page(page_path, page_data)
      end
    end

    private

    def render_page(page_path, page_data)
      # TODO: Handle missing layout and template
      layout_name = page_data[:config][:layout]

      template = ERB.new(@layouts[layout_name])
      template_result = template.result_with_hash(
        meta: page_data[:config],
        content: page_data[:content]
      )

      output_path = File.join(BUILD_DIR, "#{page_path}.html")
      File.write(output_path, template_result)
    end
  end
end
