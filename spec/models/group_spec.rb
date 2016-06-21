require 'rails_helper'

RSpec.describe Group do
  it { should have_many(:access_policies).dependent(:destroy) }
end
