# frozen_string_literal: true

require 'spec_helper'

describe SSG::ResumeRenderer do
  describe '.render' do
    before do
      allow(SSG::SiteConfig).to receive(:resume_filename).and_return('resume.pdf')
      allow(described_class).to receive(:`).and_return(nil)
    end

    it 'executes rendercv command with correct arguments' do
      expected_command = "rendercv render #{SSG::ResumeRenderer::RESUME_CONFIG_FILE} -pdf #{SSG::BUILD_DIR}/resume.pdf"

      described_class.render

      expect(described_class).to have_received(:`).with(expected_command)
    end
  end
end
