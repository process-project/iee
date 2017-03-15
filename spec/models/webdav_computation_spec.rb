require 'rails_helper'

RSpec.describe WebdavComputation, type: :model do
  it { should validate_absence_of(:script) }
  it { should validate_presence_of(:input_path) }
  it { should validate_presence_of(:output_path) }
end
