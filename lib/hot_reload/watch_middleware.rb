# frozen_string_literal: true

require 'listen'

require_relative '../config'
require_relative '../event_logger'
require_relative '../builder'

module SSG
  module HotReload
    class WatchMiddleware
      TARGET_DIRECTORIES = [ASSETS_DIR, LAYOUTS_DIR, PAGES_DIR].freeze

      def initialize(app)
        @app = app
        start_listener
      end

      def call(env)
        @app.call(env)
      end

      private

      def start_listener
        listener = Listen.to(*TARGET_DIRECTORIES) do |modified, added, removed|
          logger.debug 'Changes detected. Rebuilding site...'

          changed_files = (modified + added + removed).uniq
          logger.debug "Files changed: #{changed_files.join(', ')}"

          rebuild_site
          update_refresh_timestamp

          logger.info 'Rebuild complete.'
        end

        logger.info 'Starting file listener...'
        listener.start
      end

      def rebuild_site
        SSG::Builder.prepare_output_dir
        SSG::Builder.build
      end

      def update_refresh_timestamp
        File.write(File.join(BUILD_DIR, 'refresh.txt'), Time.now.to_s)
      end

      def logger
        @logger ||= SSG::EventLogger.new('HotReload::Watcher')
      end
    end
  end
end
