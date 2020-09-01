# frozen_string_literal: true

require 'rails_helper'

describe Pipelines::Destroy do

  let(:user) { create(:user) }
  let!(:pipeline) { create(:pipeline, user: user) }

  it 'remove pipeline from db' do

    expect { described_class.new(pipeline).call }.
      to change { Pipeline.count }.by(-1)
  end

  it 'returns true when pipeline is removed' do
    result = described_class.new(pipeline).call

    expect(result).to be_truthy
  end
end
