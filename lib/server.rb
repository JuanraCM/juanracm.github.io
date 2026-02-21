# frozen_string_literal: true

require_relative 'config'
require_relative 'event_logger'
require_relative 'hot_reload/watch_middleware'
require_relative 'hot_reload/inject_middleware'

require 'puma'
require 'rack'

module SSG
  class Server
    def initialize(port)
      @port = port
      @server = create_server
    end

    def start
      trap('INT') do
        @server.stop(true)
      end

      logger.info "Serving #{BUILD_DIR} at http://localhost:#{@port}"
      @server.run(false)
    end

    private

    def create_server
      server_logger = logger

      app = Rack::Builder.new do
        use SSG::HotReload::WatchMiddleware
        use SSG::HotReload::InjectMiddleware
        use Rack::Static, urls: [''], root: BUILD_DIR, index: 'index.html', cascade: true

        run lambda { |env|
          path = env['PATH_INFO']
          server_logger.error "File not found: #{path}" unless path == '/refresh.txt'
          [404, { 'Content-Type' => 'text/plain' }, ["File not found: #{path}"]]
        }
      end.to_app

      Puma::Server.new(app, nil).tap do |server|
        server.add_tcp_listener('0.0.0.0', @port)
      end
    end

    def logger
      @logger ||= SSG::EventLogger.new('Server')
    end
  end
end
