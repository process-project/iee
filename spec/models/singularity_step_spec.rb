# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

RSpec.describe SingularityStep do
  @my_logger ||= Logger.new("#{Rails.root}/log/debug.log")
  # before :all do
  # end
  step_name = "test_singularity_step"
  container_name = "test_container_name"
  container_tag = "test_tag"

  SingularityRegistry.add_step(step_name, [container_name])
  SingularityRegistry.add_container(container_name, [container_tag])

  let!(:singularity_script_blueprint) { create(:singularity_script_blueprint,
                                              container_name: container_name,
                                              container_tag: container_tag) }

  @my_logger.info("SingularityScriptBlueprint.all: #{SingularityScriptBlueprint.where(container_name: container_name)}")

  subject { SingularityStep.new(step_name) }

  context "Step initialized with specific name" do
    xit "obtains specific parameters from apropriate blueprint" do
        expect(subject.parameters).to include(singularity_script_blueprint.parameters)
    end 
  end

  SingularityRegistry.remove_step(step_name)
  SingularityRegistry.remove_container(container_name)

  # after :all do
  # end
end
