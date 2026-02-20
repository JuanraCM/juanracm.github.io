# frozen_string_literal: true

require 'base64'

module SSG
  module HotReload
    class InjectMiddleware
      INJECT_SNIPPET = <<~HTML
        <script>
          (function() {
            const eventSource = new EventSource('/hot-reload/events');

            eventSource.onmessage = function(event) {
              if (event.data === 'rebuild') {
                console.log('[Hot Reload] Changes detected, reloading...');
                window.location.reload();
              }
            };

            eventSource.onerror = function(error) {
              console.error('[Hot Reload] Connection error:', error);
              eventSource.close();
            };

            window.addEventListener('beforeunload', function() {
              eventSource.close();
            });

            console.info('[Hot Reload] Connected');
          })();
        </script>
      HTML

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if headers['content-type'] == 'text/html'
          modified_body = inject_html_snippet(body)
          headers['content-length'] = modified_body.bytesize.to_s

          [status, headers, [modified_body]]
        elsif headers['content-type'] == 'application/pdf'
          modified_body = wrap_pdf_in_html(body)
          headers['content-type'] = 'text/html'
          headers['content-length'] = modified_body.bytesize.to_s

          [status, headers, [modified_body]]
        else
          [status, headers, body]
        end
      end

      private

      def inject_html_snippet(raw_body)
        html = fetch_response_body(raw_body)
        html.sub('</body>', "#{INJECT_SNIPPET}</body>")
      end

      def wrap_pdf_in_html(raw_body)
        pdf_data = fetch_response_body(raw_body)
        base64_pdf = Base64.strict_encode64(pdf_data)

        <<~HTML
          <html>
            <head>
              <title>PDF Preview</title>
            </head>
            <body style="margin:0; padding:0; overflow:hidden;">
              <embed src="data:application/pdf;base64,#{base64_pdf}" type="application/pdf" width="100%" height="100%"/>
              #{INJECT_SNIPPET}
            </body>
          </html>
        HTML
      end

      def fetch_response_body(body)
        response_body = +''

        body.each { |chunk| response_body << chunk }
        body.close if body.respond_to?(:close)

        response_body
      end
    end
  end
end
