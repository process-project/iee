# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RimrockComputation, type: :model do
  subject { build(:rimrock_computation, status: :new) }

  it { should validate_presence_of(:script) }
  it { should validate_absence_of(:input_path) }
  it { should validate_absence_of(:output_path) }
  it { should validate_presence_of(:tag_or_branch) }

  it 'accepts no source input for new automatic computations only' do
    expect(build(:rimrock_computation, tag_or_branch: nil, pipeline: build(:pipeline, mode: 'manual'))).not_to be_valid
    expect(build(:rimrock_computation, tag_or_branch: '', pipeline: build(:pipeline, mode: 'manual'))).not_to be_valid
    expect(build(:rimrock_computation, tag_or_branch: 'x', pipeline: build(:pipeline, mode: 'manual'))).to be_valid
    expect(build(:rimrock_computation, tag_or_branch: nil, pipeline: build(:pipeline, mode: 'automatic'))).to be_valid
  end
end
