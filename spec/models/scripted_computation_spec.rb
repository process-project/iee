# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScriptedComputation, type: :model do
  subject { build(:scripted_computation, status: :new) }

  it { should validate_presence_of(:script) }
  it { should validate_absence_of(:input_path) }
  it { should validate_absence_of(:output_path) }
  it { should validate_presence_of(:tag_or_branch) }
  it { should validate_presence_of(:deployment) }
end
