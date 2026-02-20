# frozen_string_literal: true

require_relative 'config'
require_relative 'event_logger'
require_relative 'hot_reload/sse_middleware'

require 'listen'

module SSG
  module HotReload
    TARGET_DIRECTORIES = [ASSETS_DIR, LAYOUTS_DIR, PAGES_DIR].freeze
    SNIPPET_UPDATE_THRESHOLD = 500

    class << self
      def start
        with_changed_files do
          rebuild_site
          notify_rebuild
        end
      end

      private

      def with_changed_files
        listener = Listen.to(*TARGET_DIRECTORIES) do |modified, added, removed|
          logger.debug 'Changes detected. Rebuilding site...'

          changed_files = (modified + added + removed).uniq
          logger.debug "Files changed: #{changed_files.join(', ')}"

          yield

          logger.info 'Rebuild complete.'
        end

        logger.info 'Starting file listener...'
        listener.start
      end

      def rebuild_site
        SSG::Builder.prepare_output_dir
        SSG::Builder.build
      end

      def notify_rebuild
        SSG::HotReload::SSEMiddleware.broadcast('rebuild')
      end

      def logger
        @logger ||= SSG::EventLogger.new('HotReload')
      end
    end
  end
end
