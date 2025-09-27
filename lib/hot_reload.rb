# frozen_string_literal: true

require_relative 'config'
require_relative 'event_logger'

require 'listen'

module SSG
  module HotReload
    class << self
      def start
        listener = Listen.to(*target_directories) do |modified, added, removed|
          logger.debug 'Changes detected. Rebuilding site...'

          changed_files = (modified + added + removed).uniq
          logger.debug "Files changed: #{changed_files.join(', ')}"

          SSG::Builder.prepare_output_dir
          SSG::Builder.build

          update_refresh_timestamp

          logger.info 'Rebuild complete.'
        end

        logger.info 'Starting file listener...'
        listener.start
      end

      def target_directories
        [
          ASSETS_DIR,
          LAYOUTS_DIR,
          PAGES_DIR
        ]
      end

      def update_refresh_timestamp
        timestamp_file = File.join(BUILD_DIR, 'refresh.txt')
        File.write(timestamp_file, Time.now.to_s)
      end

      private

      def logger
        @logger ||= SSG::EventLogger.new('HotReload')
      end
    end
  end
end
