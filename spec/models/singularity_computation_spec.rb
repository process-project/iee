# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SingularityComputation, type: :model do
  let(:container_registry) { create(:container_registry) }
  subject { build(:singularity_computation, status: :new, container_registry: container_registry) }

  it { should validate_presence_of(:script) }
  it { should validate_presence_of(:container_name) }
  it { should validate_presence_of(:container_tag) }
  it { should validate_presence_of(:container_registry) }
end
