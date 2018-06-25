require 'rails_helper'

RSpec.describe UserAgent, type: :model do
  it { should validate_presence_of(:name) }
end
