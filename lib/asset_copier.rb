# frozen_string_literal: true

require 'fileutils'

module SSG
  class AssetCopier
    def self.copy_assets
      FileUtils.cp_r(SSG::ASSETS_DIR, SSG::BUILD_DIR)
    end
  end
end
