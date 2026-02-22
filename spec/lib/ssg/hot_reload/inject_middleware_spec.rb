# frozen_string_literal: true

require 'spec_helper'

describe SSG::HotReload::InjectMiddleware do
  let(:inner_app) { ->(_) { app_response } }
  let(:middleware) { described_class.new(inner_app) }
  let(:env) { { 'PATH_INFO' => '/' } }

  describe '#call' do
    context 'when the response content-type is text/html' do
      subject(:response) { middleware.call(env) }

      let(:html_body) { '<html><body><h1>Hello</h1></body></html>' }
      let(:app_response) { [200, { 'content-type' => 'text/html' }, [html_body]] }

      it 'injects the SSE script before </body>' do
        _, _, body = response

        expect(body.first).to include("new EventSource('/__hot_reload')")
      end

      it 'updates content-length to match the modified body' do
        _, headers, body = response

        expect(headers['content-length']).to eq(body.first.bytesize.to_s)
      end

      it 'preserves the original status code' do
        status, = response

        expect(status).to eq(200)
      end
    end

    context 'when the response content-type is application/pdf' do
      subject(:response) { middleware.call(env) }

      let(:pdf_data) { '%PDF-1.4 fake pdf content' }
      let(:app_response) { [200, { 'content-type' => 'application/pdf' }, [pdf_data]] }

      it 'encodes the PDF data' do
        _, _, body = response
        expected_b64 = Base64.strict_encode64(pdf_data)

        expect(body.first).to include(expected_b64)
      end

      it 'injects the SSE script into the PDF wrapper page' do
        _, _, body = response

        expect(body.first).to include("new EventSource('/__hot_reload')")
      end

      it 'changes the content-type to text/html' do
        _, headers, = response
        expect(headers['content-type']).to eq('text/html')
      end

      it 'updates content-length to match the modified body' do
        _, headers, body = response

        expect(headers['content-length']).to eq(body.first.bytesize.to_s)
      end
    end

    context 'when the response content-type is neither text/html nor application/pdf' do
      subject(:response) { middleware.call(env) }

      let(:css_body) { 'body { color: red; }' }
      let(:app_response) { [200, { 'content-type' => 'text/css' }, [css_body]] }

      it 'passes the body response through unchanged' do
        _, _, body = response

        expect(body).to eq([css_body])
      end
    end
  end
end
