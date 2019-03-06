# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RimrockComputation, type: :model do
  subject { build(:rimrock_computation, status: :new) }

  it { should validate_presence_of(:script) }
  it { should validate_absence_of(:input_path) }
  it { should validate_absence_of(:output_path) }
  it { should validate_presence_of(:tag_or_branch) }

  it 'is properly configured only if tag or branch is set' do
    expect(build(:rimrock_computation, tag_or_branch: nil)).not_to be_configured
    expect(build(:rimrock_computation, tag_or_branch: '')).not_to be_configured
    expect(build(:rimrock_computation, tag_or_branch: 'x')).to be_configured
  end
end
