# frozen_string_literal: true

require 'rails_helper'

describe Pipelines::StepsConfig do
  it 'loads tags and branches for every scripted computation' do
    versions = { branches: %w[b1 b2], tags: %w[t1] }
    allow(Gitlab::Versions).
      to receive_message_chain(:new, :call).
      and_return(versions)

    config = described_class.new('avr_from_scan_rom').call
    expect(config['rom']).
      to eq(tags_and_branches: versions, deployment: %w[cluster cloud], run_modes: nil)
    expect(config['segmentation'][:run_modes]).
      to include('Workflow 5 (Mitral Valve TEE Segmentation)')
  end
end
