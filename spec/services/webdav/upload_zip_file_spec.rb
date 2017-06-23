# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Webdav::UploadZipFile do
  include WebDavSpecHelper

  let(:dav_client) { double(:dav) }
  let(:local_path) { 'spec/support/data_files/foo.zip' }
  let(:remote_directory) { '/remote/' }

  it 'uploads zip content to webdav' do
    expect_put(dav_client, File.join(remote_directory, 'foo.txt'), 4)
    expect_put(dav_client, File.join(remote_directory, 'bar.txt'), 4)
    expect_put(dav_client, File.join(remote_directory, 'quux.txt'), 5)

    described_class.new(dav_client, local_path, remote_directory).call
  end

  it 'allows unzipped files names modification' do
    expect_put(dav_client, File.join(remote_directory, 'foo.txt.new'), 4)
    expect_put(dav_client, File.join(remote_directory, 'bar.txt.new'), 4)
    expect_put(dav_client, File.join(remote_directory, 'quux.txt.new'), 5)

    described_class.new(dav_client, local_path, remote_directory).
      call { |f| "#{f}.new" }
  end
end
