# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::DownloadOutput do
  let(:output_remote_path) { '/remote/path' }

  it 'creates a dav client for owncloud' do
    expect(WebdavClient).to receive(:new).with(
      Rails.application.config_for('eurvalve')['owncloud']['url'],
      expected_options
    )
    described_class.new(output_remote_path)
  end

  private

  def expected_options
    {
      verify_server: false,
      username: Rails.application.config_for('eurvalve')['owncloud']['user'],
      password: Rails.application.config_for('eurvalve')['owncloud']['password']
    }
  end
end
