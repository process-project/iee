# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::UploadOutput do
  let(:dav_client) { double(:dav) }
  let(:file_path) { '/file/path' }

  it 'puts given file to WebDav' do
    allow(WebdavClient).to receive(:new).and_return dav_client
    expect(dav_client).to receive(:put_file).with(file_path, anything)
    described_class.send(:new, file_path, 'remote/output/path', 'token').call
  end
end
