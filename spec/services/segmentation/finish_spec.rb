# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::Finish do
  include WebDavSpecHelper

  let(:file_store) { instance_double(Webdav::FileStore) }
  let(:segmentation) { instance_double(Webdav::Segmentation) }
  let(:updater) { double.tap { |d| allow(d).to receive_message_chain(:new, :call) } }

  it 'push results into FileStore' do
    computation = create(:computation,
                         working_file_name: 'prefix.zip',
                         output_path: 'segmentation/output')

    expect(segmentation).to receive(:get_file) do |remote_path, local_file_path|
      expect(remote_path).to eq 'segmentation/output/prefix.zip'
      FileUtils.cp('spec/support/data_files/segmentation-output.zip',
                   local_file_path)
    end

    expect_put(file_store, 'segmentation/output/prefix.txt', 5)
    expect_put(file_store, 'segmentation/output/infix--tail.foo', 4)
    expect_put(file_store, 'segmentation/output/bar.txt', 4)
    expect_put(file_store, 'segmentation/output/secondprefix.txt', 4)

    described_class.new(computation, updater,
                        segmentation: segmentation, file_store: file_store).call

    expect(computation.status).to eq 'finished'
  end

  it 'sets status to error while result upload failed' do
    computation = create(:computation,
                         working_file_name: 'prefix.zip',
                         output_path: 'segmentation/output')

    expect(segmentation).to receive(:get_file) do |remote_path, local_file_path|
      expect(remote_path).to eq 'segmentation/output/prefix.zip'
      FileUtils.cp('spec/support/data_files/bad.zip',
                   local_file_path)
    end

    described_class.new(computation, updater,
                        segmentation: segmentation, file_store: file_store).call

    expect(computation.status).to eq 'error'
    expect(computation.error_message).not_to be_nil
    expect(computation.error_message).not_to be_empty
  end
end
