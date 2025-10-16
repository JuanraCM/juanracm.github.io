# frozen_string_literal: true

require 'erb'

require_relative 'config'
require_relative 'site_config'

module SSG
  class ViewContext
    class InvalidLayoutError < SSGError; end

    attr_reader :meta, :content

    def initialize(layouts, page_data)
      @layouts = layouts
      @meta = page_data[:config] || {}
      @content = page_data[:content] || ''

      @_render_blocks = {}
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

    def yield_content(name = :body, &block)
      if block_given?
        @_render_blocks[name] = capture(&block)
      else
        @_render_blocks[name]
      end
    end

    def render_template(template_name, &block)
      layout = @layouts[template_name]
      raise InvalidLayoutError, "Layout '#{template_name}' not found" unless layout

      @_render_blocks[:body] = capture(&block) if block_given?

      template = ERB.new(layout)
      template.result(binding)
    end

    def capture(&block)
      buf_was = block.binding.local_variable_get(:_erbout)
      out_buf = +''

      block.binding.local_variable_set(:_erbout, out_buf)
      block.call

      out_buf
    ensure
      block.binding.local_variable_set(:_erbout, buf_was)
    end

    def site
      SiteConfig
    end

    def page_class
      @page_class || ''
    end
  end
end
