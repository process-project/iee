# frozen_string_literal: true

require 'rails_helper'
require 'models/step_shared_examples'

describe ParameterFetcher do
  step_name = 'testing_singularity_step'
  container_name = 'testing_container_name'
  container_tag = 'test_tag'

  let!(:compute_site) do
    create(
      :compute_site
    )
  end

  let!(:ssbp) do
    create(
      :singularity_script_blueprint,
      container_name: container_name,
      container_tag: container_tag,
      compute_site: compute_site
    )
  end

  before(:each) do
    SingularityRegistry = double('SingularityRegistry')
    allow(SingularityRegistry).to receive(:fetch_containers).with(step_name) do
      STEPS = { step_name.to_sym => [container_name] }.freeze
      CONTAINERS = { container_name => [container_tag] }.freeze
      container_names = STEPS.fetch(step_name.to_sym)
      result_containers = {}
      CONTAINERS.each do |container, tags|
        result_containers[container] = tags if container_names.include? container
      end
      result_containers
    end
  end

  context 'Initialized with specific step name' do
    it 'obtains specific parameters from apropriate blueprint' do
      parameter_fetcher = ParameterFetcher.new(step_name, SingularityRegistry)
      expect(parameter_fetcher.call).to include(ssbp.step_parameters.to_a.first)
    end
  end
end
