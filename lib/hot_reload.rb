# frozen_string_literal: true

require_relative 'config'
require_relative 'event_logger'

require 'listen'

module SSG
  module HotReload
    class << self
      def start
        @enabled = true
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
            }, 500);
          </script>
        HTML

        html.sub!('</body>', "#{hr_snippet}</body>")
      end

      private

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

      def logger
        @logger ||= SSG::EventLogger.new('HotReload')
      end
    end
  end
end
