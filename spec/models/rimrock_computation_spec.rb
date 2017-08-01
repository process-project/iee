# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RimrockComputation, type: :model do
  subject { build(:rimrock_computation, status: :new) }

  it { should validate_presence_of(:script) }
  it { should validate_absence_of(:input_path) }
  it { should validate_absence_of(:output_path) }
  it { should validate_presence_of(:revision) }
end
