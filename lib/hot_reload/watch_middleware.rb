# frozen_string_literal: true

require 'listen'

require_relative '../config'
require_relative '../event_logger'
require_relative '../builder'

module SSG
  module HotReload
    class WatchMiddleware
      REFRESH_FILE = File.join(BUILD_DIR, 'refresh.txt')
      TARGET_PATHS = [
        ASSETS_DIR,
        LAYOUTS_DIR,
        PAGES_DIR,
        RESUME_CONFIG_FILE,
        SITE_CONFIG_FILE
      ].freeze

      def initialize(app)
        @app = app
        start_listener
      end

      def call(env)
        if env['PATH_INFO'] == '/refresh.txt' && !File.exist?(REFRESH_FILE)
          return [200, { 'Content-Type' => 'text/plain' }, ['']]
        end

        @app.call(env)
      end

      private

      def start_listener
        listener = Listen.to(ROOT_DIR) do |modified, added, removed|
          changed_files = filter_changed_files(modified, added, removed)
          next if changed_files.empty?

          logger.debug 'Changes detected. Rebuilding site...'
          logger.debug "Files changed: #{changed_files.join(', ')}"

          rebuild_site

          logger.info 'Rebuild complete.'
        end

        logger.info 'Starting file listener...'
        listener.start
      end

      def filter_changed_files(modified, added, removed)
        unique_files = (modified + added + removed).uniq
        unique_files.select do |file|
          TARGET_PATHS.any? { |target| file.start_with?(target) }
        end
      end

      def rebuild_site
        SSG::Builder.prepare_output_dir
        SSG::Builder.build

        update_refresh_timestamp
      end

      def update_refresh_timestamp
        File.write(File.join(REFRESH_FILE), Time.now.to_s)
      end

      def logger
        @logger ||= SSG::EventLogger.new('HotReload::Watcher')
      end
    end
  end
end
