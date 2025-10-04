# frozen_string_literal: true

require_relative 'config'
require_relative 'event_logger'

require 'listen'

module SSG
  module HotReload
    TARGET_DIRECTORIES = [ASSETS_DIR, LAYOUTS_DIR, PAGES_DIR].freeze
    SNIPPET_UPDATE_THRESHOLD = 500

    class << self
      def start
        @enabled = true

        with_changed_files do
          rebuild_site
          update_refresh_timestamp
        end
      end

      def inject_html_snippet(html)
        return html unless @enabled

        hr_snippet = <<~HTML
          <script>
            let refreshedAt;

            setInterval(() => {
              console.info('Checking for updates...');

              fetch('refresh.txt')
                .then(response => response.text())
                .then(data => {
                  if (refreshedAt && refreshedAt !== data) {
                    window.location.reload();
                  }
                  refreshedAt = data;
                });
            }, #{SNIPPET_UPDATE_THRESHOLD});
          </script>
        HTML

        html.sub!('</body>', "#{hr_snippet}</body>")
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

      def update_refresh_timestamp
        timestamp_file = File.join(BUILD_DIR, 'refresh.txt')
        File.write(timestamp_file, Time.now.to_s)
      end

      def logger
        @logger ||= SSG::EventLogger.new('HotReload')
      end
    end
  end
end
