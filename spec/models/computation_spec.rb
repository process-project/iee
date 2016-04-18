require 'rails_helper'

RSpec.describe Computation, type: :model do
  it { should validate_presence_of(:script) }
  it { should validate_presence_of(:user) }
  it { should validate_uniqueness_of(:working_directory) }

  it { should belong_to(:user) }
end
