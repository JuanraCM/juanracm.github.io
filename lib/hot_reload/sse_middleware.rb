# frozen_string_literal: true

module SSG
  module HotReload
    class SSEMiddleware
      HR_PATH = '/hot-reload/events'

      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless env['PATH_INFO'] == HR_PATH

        body = lambda do |stream|
          5.times do
            stream.write("data: ping\n\n")
            stream.flush
            sleep 1
          end
        end

        [
          200,
          {
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive'
          },
          body
        ]
      end
    end
  end
end
