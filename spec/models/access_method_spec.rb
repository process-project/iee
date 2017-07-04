# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessMethod do
  subject { build(:access_method) }

  it { should validate_presence_of(:name) }

  it do
    should(validate_uniqueness_of(:name).
           case_insensitive.
           scoped_to(:service_id))
  end

  it { should have_many(:access_policies).dependent(:destroy) }
end
