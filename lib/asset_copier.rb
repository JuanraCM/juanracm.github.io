# frozen_string_literal: true

require 'fileutils'

require_relative 'config'

module SSG
  class AssetCopier
    def self.copy_assets
      FileUtils.cp_r(ASSETS_DIR, BUILD_DIR)
    end
  end
end
