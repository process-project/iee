require 'rails_helper'

RSpec.describe Computation, type: :model do
  subject { build(:computation) }

  it { should validate_presence_of(:script) }
  it { should validate_presence_of(:user) }

  it { should belong_to(:user) }
end
