# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webdav::DownloadFile do
  let(:dav_client) { double(:dav) }
  let(:remote_path) { '/remote/path.txt' }

  it 'fetches given file from WebDav' do
    expect(dav_client).to receive(:get_file).with(remote_path, anything)
    path = described_class.new(dav_client, remote_path).call

    expect(path).to start_with('/tmp')
    expect(path).to end_with('path.txt')
  end

  it 'allows to update destination file name' do
    allow(dav_client).to receive(:get_file)
    path = described_class.new(dav_client, remote_path).call { |f| "#{f}.new" }

    expect(path).to end_with('path.txt.new')
  end
end
