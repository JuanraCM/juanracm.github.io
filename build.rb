# frozen_string_literal: true

require 'fileutils'
require 'commonmarker'
require 'yaml'
require 'erb'

LAYOUTS_DIR = 'layouts'
PAGES_DIR   = 'pages'
OUTPUT_DIR  = 'build'

# Prepare output directory
FileUtils.rm_rf(OUTPUT_DIR)
FileUtils.mkdir_p(OUTPUT_DIR)

# Load layouts
layouts = {}
Dir.glob("#{LAYOUTS_DIR}/*.html.erb") do |layout_file|
  layout_name = File.basename(layout_file, '.html.erb')
  layouts[layout_name] = File.read(layout_file)
end

# Process pages
pages = {}
Dir.glob("#{PAGES_DIR}/**/*.md") do |page_file|
  page_path = page_file.sub("#{PAGES_DIR}/", '').sub('.md', '')

  page_content   = File.read(page_file)
  parsed_content = Commonmarker.parse(
    page_content,
    options: { extension: { front_matter_delimiter: '---' } }
  )

  # TODO: Handle missing front matter
  front_matter = parsed_content.first
  page_config  = YAML.safe_load(front_matter.to_commonmark).transform_keys(&:to_sym)

  pages[page_path] = {
    config: page_config,
    content: parsed_content.to_html
  }
end

# Render pages
pages.each do |page_path, page_data|
  # TODO: Handle missing layout and template
  layout_name = page_data[:config][:layout]
  layouts[layout_name]

  template = ERB.new(layouts[layout_name])
  template_result = template.result_with_hash(
    meta: page_data[:config],
    content: page_data[:content]
  )

  output_path = File.join(OUTPUT_DIR, "#{page_path}.html")
  File.write(output_path, template_result)
end

# Copy static assets
FileUtils.cp_r('assets', OUTPUT_DIR)
