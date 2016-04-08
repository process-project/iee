require 'rails_helper'

RSpec.describe DataFile do
  subject { build(:data_file) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:data_type) }
  it { should validate_presence_of(:patient) }
end
