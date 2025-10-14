# frozen_string_literal: true

require_relative 'config'
require_relative 'hot_reload'
require_relative 'view_context'

module SSG
  class PageRenderer
    class MissingLayoutError < SSGError; end

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
      layout_name = page_data[:config][:layout]
      raise_missing_layout_error(page_path) unless layout_name

      rendered_page = ViewContext.new(@layouts, page_data).render
      HotReload.inject_html_snippet(rendered_page)

      output_path = File.join(BUILD_DIR, "#{page_path}.html")

      FileUtils.mkdir_p(File.dirname(output_path))
      File.write(output_path, rendered_page)
    end

    def raise_missing_layout_error(path)
      raise MissingLayoutError, "Layout not specified for path: #{path}"
    end
  end
end
