# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Webdav::UploadZipFile do
  let(:dav_client) { double(:dav) }
  let(:local_path) { 'spec/support/data_files/foo.zip' }
  let(:remote_directory) { '/remote/' }

  it 'uploads zip content to webdav' do
    expect_put('foo.txt', 4)
    expect_put('bar.txt', 4)
    expect_put('quux.txt', 5)

    described_class.new(dav_client, local_path, remote_directory).call
  end

  def expect_put(file_name, size)
    expect(dav_client).
      to receive(:put).
      with(File.join(remote_directory, file_name), anything, size)
  end
end
