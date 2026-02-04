# frozen_string_literal: true

require 'fileutils'

require_relative 'config'
require_relative 'site_config'

module SSG
  class ResumeRenderer
    RESUME_CONFIG_FILE = File.join(ROOT_DIR, 'resume.yml').freeze

    def self.render
      `rendercv render #{RESUME_CONFIG_FILE} -pdf #{BUILD_DIR}/#{SiteConfig.resume_filename}`
    end
  end
end
