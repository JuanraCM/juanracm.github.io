# frozen_string_literal: true

require 'spec_helper'

describe SSG::ResumeRenderer do
  describe '.render' do
    let(:expected_command) { "rendercv render #{SSG::ResumeRenderer::RESUME_CONFIG_FILE} -pdf #{SSG::BUILD_DIR}/resume.pdf" }
    let(:success_status) { instance_double(Process::Status, success?: true, exitstatus: 0) }
    let(:failure_status) { instance_double(Process::Status, success?: false, exitstatus: 127) }

    before do
      allow(SSG::SiteConfig).to receive(:resume_filename).and_return('resume.pdf')
    end

    context 'when the command succeeds' do
      before do
        allow(Open3).to receive(:capture2e).and_return(['Success output', success_status])
      end

      it 'executes rendercv command with correct arguments' do
        described_class.render

        expect(Open3).to have_received(:capture2e).with(expected_command)
      end

      it 'does not raise an error' do
        expect { described_class.render }.not_to raise_error
      end
    end

    context 'when the command fails' do
      before do
        allow(Open3).to receive(:capture2e).and_return(['Error: rendercv not found', failure_status])
      end

      it 'raises ResumeRenderError with exit code and output' do
        expect { described_class.render }.to raise_error(
          SSG::ResumeRenderer::ResumeRenderError,
          /Failed to render resume \(exit code: 127\): Error: rendercv not found/
        )
      end
    end
  end
end
