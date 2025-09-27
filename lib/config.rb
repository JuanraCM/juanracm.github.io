# frozen_string_literal: true

module SSG
  class SSGError < StandardError; end

  ROOT_DIR    = File.expand_path('..', __dir__)
  LAYOUTS_DIR = File.join(ROOT_DIR, 'layouts')
  PAGES_DIR   = File.join(ROOT_DIR, 'pages')
  ASSETS_DIR  = File.join(ROOT_DIR, 'assets')
  BUILD_DIR   = File.join(ROOT_DIR, 'build')
end
