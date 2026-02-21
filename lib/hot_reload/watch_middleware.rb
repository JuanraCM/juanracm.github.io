# frozen_string_literal: true

require 'listen'

require_relative '../config'
require_relative '../event_logger'
require_relative '../builder'

module SSG
  module HotReload
    class WatchMiddleware
      SSE_PATH = '/__hot_reload'
      TARGET_PATHS = [
        ASSETS_DIR,
        LAYOUTS_DIR,
        PAGES_DIR,
        RESUME_CONFIG_FILE,
        SITE_CONFIG_FILE
      ].freeze

      def initialize(app)
        @app     = app
        @clients = []
        @mutex   = Mutex.new

        start_listener
      end

      def call(env)
        return sse_response if env['PATH_INFO'] == SSE_PATH

        @app.call(env)
      end

      private

      def sse_response
        [
          200,
          {
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive'
          },
          proc { |client| handle_sse_response(client) }
        ]
      end

      def handle_sse_response(client)
        @mutex.synchronize { @clients << client }

        loop do
          sleep 1
          client.write(": keep-alive\n\n")
          client.flush
        end
      rescue IOError, Errno::EPIPE
        client.close
        @mutex.synchronize { @clients.delete(client) }
      end

      def notify_clients
        @mutex.synchronize do
          @clients.reject! do |client|
            client.write("data: refresh\n\n")
            client.flush

            false
          rescue IOError, Errno::EPIPE
            client.close
            true
          end
        end
      end

      def start_listener
        listener = Listen.to(ROOT_DIR) do |modified, added, removed|
          changed_files = filter_changed_files(modified, added, removed)
          next if changed_files.empty?

          logger.debug 'Changes detected. Rebuilding site...'
          logger.debug "Files changed: #{changed_files.join(', ')}"

          rebuild_site
          notify_clients

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
      end

      def logger
        @logger ||= SSG::EventLogger.new('HotReload::WatchMiddleware')
      end
    end
  end
end
