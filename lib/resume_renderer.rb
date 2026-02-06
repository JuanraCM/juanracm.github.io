# frozen_string_literal: true

require 'fileutils'
require 'open3'

require_relative 'config'
require_relative 'site_config'

module SSG
  class ResumeRenderer
    class ResumeRenderError < SSGError; end

    RESUME_CONFIG_FILE = File.join(ROOT_DIR, 'resume.yml').freeze

    def self.render
      command = "rendercv render #{RESUME_CONFIG_FILE} -pdf #{BUILD_DIR}/#{SiteConfig.resume_filename}"
      output, status = Open3.capture2e(command)

      return if status.success?

      raise ResumeRenderError, "Failed to render resume (exit code: #{status.exitstatus}): #{output}"
    end
  end
end
