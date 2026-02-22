# frozen_string_literal: true

require 'spec_helper'

describe SSG::Server do
  let(:port) { 4567 }
  let(:puma_server_double) do
    instance_double(Puma::Server, add_tcp_listener: nil, run: nil, stop: nil)
  end
  let(:listener_double) { instance_double(Listen::Listener, start: nil) }
  let(:server) { described_class.new(port) }

  before do
    allow(Puma::Server).to receive(:new).and_return(puma_server_double)
    allow(Listen).to receive(:to).and_return(listener_double)
  end

  describe '#initialize' do
    it 'creates a Puma server bound to the given port' do
      server

      expect(puma_server_double).to have_received(:add_tcp_listener).with('0.0.0.0', port)
    end
  end

  describe '#start' do
    before do
      allow(Signal).to receive(:trap)
      allow(server).to receive(:trap).with('INT')

      server.start
    end

    it 'runs the Puma server in blocking mode' do
      expect(puma_server_double).to have_received(:run).with(false)
    end

    it 'registers a SIGINT trap' do
      expect(server).to have_received(:trap).with('INT')
    end
  end

  describe 'SIGINT handler' do
    let(:watch_middleware_instance) do
      instance_double(SSG::HotReload::WatchMiddleware, shutdown: nil)
    end

    before do
      allow(SSG::HotReload::WatchMiddleware)
        .to receive(:instance).and_return(watch_middleware_instance)

      trap_block = nil
      allow(server).to receive(:trap).with('INT') { |&block| trap_block = block }

      server.start
      trap_block.call
    end

    it 'stops the Puma server' do
      expect(puma_server_double).to have_received(:stop).with(true)
    end

    it 'shuts down the watch middleware' do
      expect(watch_middleware_instance).to have_received(:shutdown)
    end
  end
end
