# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::Finish do
  include WebDavSpecHelper

  let(:file_store) { instance_double(Webdav::FileStore) }
  let(:own_cloud) { instance_double(Webdav::OwnCloud) }
  let(:updater) { double.tap { |d| allow(d).to receive_message_chain(:new, :call) } }

  it 'push results into FileStore' do
    computation = create(:computation,
                         working_file_name: 'prefix.zip',
                         output_path: 'output')

    expect(own_cloud).to receive(:get_file) do |remote_path, local_file_path|
      expect(remote_path).to eq 'output/prefix.zip'
      FileUtils.cp('spec/support/data_files/segmentation-output.zip',
                   local_file_path)
    end

    expect_put(file_store, 'output/prefix.txt', 5)
    expect_put(file_store, 'output/bar.txt', 4)
    expect_put(file_store, 'output/secondprefix.txt', 4)

    described_class.new(computation, updater,
                        own_cloud: own_cloud, file_store: file_store).call

    expect(computation.status).to eq 'finished'
  end

  it 'push broken results into FileStore' do
    computation = create(:computation,
                         working_file_name: 'prefix.zip',
                         output_path: 'output')

    expect(own_cloud).to receive(:get_file) do |remote_path, local_file_path|
      expect(remote_path).to eq 'output/prefix.zip'
      FileUtils.cp('spec/support/data_files/bad.zip',
                   local_file_path)
    end

    described_class.new(computation, updater,
                        own_cloud: own_cloud, file_store: file_store).call

    expect(computation.status).to eq 'error'
    expect(computation.error_message).not_to be_nil
    expect(computation.error_message).not_to be_empty
  end
end
