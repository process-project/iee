# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device, type: :model do
  it { should have_many(:ips).dependent(:destroy) }
  it { should validate_presence_of(:name) }
end
