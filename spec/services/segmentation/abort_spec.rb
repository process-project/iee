# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::Abort do
  include WebDavSpecHelper

  let(:segmentation) { instance_double(Webdav::Segmentation) }
  let(:updater) { double.tap { |d| allow(d).to receive_message_chain(:new, :call) } }

  context 'active computation' do
    let!(:computation) do
      create(:webdav_computation,
             status: :running, working_file_name: '3_input.zip')
    end

    before { allow(segmentation).to receive(:delete) }

    it 'removes active computation input file from segmenation input' do
      expect(segmentation).
        to receive(:delete).
        with(Webdav::Segmentation.input_path(computation))

      call(computation)
    end

    it 'changes active computation state into aborted' do
      expect { call(computation) }.to change { computation.status }.to('aborted')
    end

    it 'updates about status change' do
      expect(updater).to receive_message_chain(:new, :call)

      call(computation)
    end
  end

  it 'does nothing for non active computations' do
    computation = create(:webdav_computation, status: :finished)

    expect(updater).to_not receive(:new)
    expect { call(computation) }.to_not change { computation.status }
  end

  def call(computation)
    described_class.new(computation, updater, segmentation: segmentation).call
  end
end
