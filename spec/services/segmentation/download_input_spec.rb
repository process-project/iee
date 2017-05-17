# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::DownloadInput do
  let(:input_remote_path) { '/remote/path' }
  let(:token) { 'jwt' }

  it 'creates a dav client for filestore' do
    expect(WebdavClient).to receive(:new).with(
      Rails.application.config_for('application')['file_store']['web_dav_base_url'],
      expected_options
    )
    described_class.new(input_remote_path, token)
  end

  private

  def expected_options
    { headers: { 'Authorization' => "Bearer #{token}" } }
  end
end
