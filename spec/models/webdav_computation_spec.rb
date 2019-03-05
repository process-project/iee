# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebdavComputation, type: :model do
  it { should validate_absence_of(:script) }
  it { should validate_presence_of(:output_path) }

  it 'is properly configured only if run mode is set' do
    expect(build(:webdav_computation, run_mode: nil)).not_to be_configured
    expect(build(:webdav_computation, run_mode: '')).not_to be_configured
    expect(build(:webdav_computation, run_mode: 'x')).to be_configured
  end
end
