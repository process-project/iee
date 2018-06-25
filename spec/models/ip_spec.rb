require 'rails_helper'

RSpec.describe Ip, type: :model do
  it { should validate_presence_of(:address) }
end
