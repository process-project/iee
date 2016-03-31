require 'rails_helper'

RSpec.describe Group do
  it { should have_many(:permissions).dependent(:destroy) }
end
