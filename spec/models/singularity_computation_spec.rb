# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SingularityComputation, type: :model do
  subject { build(:singularity_computation, status: :new) }

  it { should validate_presence_of(:script) }
  it { should validate_presence_of(:container_name) }
  it { should validate_presence_of(:registry_url) }
  it { should validate_presence_of(:container_tag) }
end