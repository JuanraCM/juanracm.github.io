# frozen_string_literal: true

module SSG
  class SSGError < StandardError; end

  ROOT_DIR    = File.expand_path('..', __dir__)
  LAYOUTS_DIR = File.join(ROOT_DIR, 'layouts')
  PAGES_DIR   = File.join(ROOT_DIR, 'pages')
  ASSETS_DIR  = File.join(ROOT_DIR, 'assets')
  BUILD_DIR   = File.join(ROOT_DIR, 'build')

  SITE_CONFIG_FILE   = File.join(ROOT_DIR, 'site.yml').freeze
  RESUME_CONFIG_FILE = File.join(ROOT_DIR, 'resume.yml').freeze
end
