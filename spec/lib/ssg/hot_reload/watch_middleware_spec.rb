# frozen_string_literal: true

require 'spec_helper'

describe SSG::HotReload::WatchMiddleware do
  let(:inner_app) { ->(_) { [200, { 'Content-Type' => 'text/html' }, ['OK']] } }
  let(:listener_double) { instance_double(Listen::Listener, start: nil) }
  let(:middleware) { described_class.new(inner_app) }

  before do
    allow(Listen).to receive(:to).and_return(listener_double)
  end

  describe '#initialize' do
    it 'starts the file listener' do
      middleware
      expect(listener_double).to have_received(:start)
    end

    it 'registers itself as the class-level instance' do
      m = middleware
      expect(described_class.instance).to eq(m)
    end
  end

  describe '#call' do
    context 'when the request path is the SSE endpoint' do
      subject(:response) { middleware.call(env) }

      let(:env) { { 'PATH_INFO' => SSG::HotReload::WatchMiddleware::SSE_PATH } }

      it 'returns a 200 status' do
        status, = response

        expect(status).to eq(200)
      end

      it 'sets SSE specific headers' do
        _, headers, = response

        expect(headers).to include(
          'Content-Type' => 'text/event-stream',
          'Cache-Control' => 'no-cache'
        )
      end

      it 'returns a streaming body (Proc)' do
        _, _, body = response

        expect(body).to be_a(Proc)
      end

      it 'does not forward the request to the inner app' do
        allow(inner_app).to receive(:call).and_call_original
        middleware.call(env)

        expect(inner_app).not_to have_received(:call)
      end
    end

    context 'when the request path is not the SSE endpoint' do
      let(:env) { { 'PATH_INFO' => '/index.html' } }

      it 'delegates to the inner app' do
        allow(inner_app).to receive(:call).and_call_original
        middleware.call(env)

        expect(inner_app).to have_received(:call).with(env)
      end
    end
  end

  describe '#shutdown' do
    it 'sets the shutdown flag' do
      expect { middleware.shutdown }
        .to change { middleware.instance_variable_get(:@shutdown) }.from(false).to(true)
    end
  end
end
