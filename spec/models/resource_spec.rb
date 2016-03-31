require 'rails_helper'

RSpec.describe Resource do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:uri) }
  it { should have_many(:permissions).dependent(:destroy) }
end
