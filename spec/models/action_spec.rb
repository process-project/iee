require 'rails_helper'

RSpec.describe Action do
  subject { build(:action) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should have_many(:permissions).dependent(:destroy) }
end
