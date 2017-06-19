# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webdav::UploadZipFile do
  let(:dav_client) { double(:dav) }
  let(:local_path) { 'spec/support/data_files/foo.zip' }
  let(:remote_directory) { '/remote/' }

  it 'uploads zip content to webdav' do
    expect(dav_client).to receive(:put_file).with(anything, File.join(remote_directory, 'foo.txt'))
    expect(dav_client).to receive(:put_file).with(anything, File.join(remote_directory, 'bar.txt'))
    expect(dav_client).to receive(:put_file).with(anything, File.join(remote_directory, 'quux.txt'))
    described_class.new(dav_client, local_path, remote_directory).call
  end
end
