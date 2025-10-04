# frozen_string_literal: true

require 'erb'

require_relative 'config'
require_relative 'hot_reload'

module SSG
  class PageRenderer
    class MissingLayoutError < SSGError; end
    class MissingTemplateError < SSGError; end

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
      raise_missing_template_error(layout_name, page_path) unless @layouts.key?(layout_name)

      template = ERB.new(@layouts[layout_name])
      template_result = template.result_with_hash(
        site: SiteConfig,
        meta: page_data[:config],
        content: page_data[:content]
      )
      SSG::HotReload.inject_html_snippet(template_result)

      output_path = File.join(BUILD_DIR, "#{page_path}.html")

      FileUtils.mkdir_p(File.dirname(output_path))
      File.write(output_path, template_result)
    end

    def raise_missing_layout_error(path)
      raise MissingLayoutError, "Layout not specified for path: #{path}"
    end

    def raise_missing_template_error(layout, path)
      raise MissingTemplateError, "Layout '#{layout}' not found for #{path}"
    end
  end
end
