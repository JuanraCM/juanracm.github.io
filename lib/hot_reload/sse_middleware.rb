# frozen_string_literal: true

module SSG
  module HotReload
    class SSEMiddleware
      HR_PATH = '/hot-reload/events'

      @mutex = Mutex.new
      @connections = []

      class << self
        def broadcast(event)
          @mutex.synchronize do
            @connections.each do |stream|
              stream.write("data: #{event}\n\n")
              stream.flush
              stream.close
            end
          end
        end

        def add_connection(stream)
          @mutex.synchronize { @connections << stream }
        end

        def remove_connection(stream)
          @mutex.synchronize { @connections.delete(stream) }
        end

        def remove_all_connections
          Thread.new do # TODO: Find out why this is needed
            @mutex.synchronize do
              @connections.each(&:close)
              @connections.clear
            end
          end
        end
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless env['PATH_INFO'] == HR_PATH

        [
          200,
          {
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive'
          },
          proc { |stream| stream_response(stream) }
        ]
      end

      private

      def stream_response(stream)
        self.class.add_connection(stream)

        loop do
          sleep 1
          break if stream.closed?

          begin
            stream.write(": keepalive\n\n")
            stream.flush
          rescue Errno::EPIPE, IOError
            break
          end
        end
      ensure
        self.class.remove_connection(stream)
      end
    end
  end
end
