# frozen_string_literal: true

require_relative 'config'

module SSG
  class LayoutLoader
    def self.load_all
      layouts = {}

      Dir.glob("#{LAYOUTS_DIR}/*.html.erb") do |layout_file|
        layout_name = File.basename(layout_file, '.html.erb')
        layouts[layout_name] = File.read(layout_file)
      end

      layouts
    end
  end
end
