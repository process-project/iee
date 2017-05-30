# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::DownloadFile do
  let(:dav_client) { double(:dav) }
  let(:remote_path) { '/remote/path' }

  it 'fetches given file from WebDav' do
    expect(dav_client).to receive(:get_file).with(remote_path, anything)
    described_class.send(:new, dav_client, remote_path).call
  end

  it 'returns local file path' do
    allow(dav_client).to receive(:get_file)
    result = described_class.send(:new, dav_client, remote_path).call
    expect(result)
  end
end
