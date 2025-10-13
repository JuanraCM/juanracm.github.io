# frozen_string_literal: true

require 'erb'

require_relative 'config'
require_relative 'site_config'

module SSG
  class ViewContext
    attr_reader :meta, :content

    def initialize(layouts, page_data)
      @layouts = layouts
      @meta = page_data[:config] || {}
      @content = page_data[:content] || ''
    end

    def render
      render_result = render_template(@meta[:layout])

      @layout_result || render_result
    end

    private

    def layout(name, page_class: '', &block)
      @page_class = page_class
      @layout_result = render_template(name, &block)
    end

    def render_template(template_name)
      template = ERB.new(@layouts[template_name])
      template.result(binding)
    end

    def site
      SiteConfig
    end

    def page_class
      @page_class || ''
    end
  end
end
