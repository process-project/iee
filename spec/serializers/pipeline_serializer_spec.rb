# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe PipelineSerializer do
  it 'serializes full pipeline data with computations' do
    pipeline = create(:pipeline, :with_computations, iid: 1, flow: 'unused_steps')

    json = JSON.parse(described_class.new(pipeline, include: [:computations]).serialized_json)

    expect(json).to include_json(
      data: {
        type: 'pipeline',
        id: pipeline.iid.to_s,
        attributes: {
          name: pipeline.name,
          flow: "unused_steps",
          inputs_dir: "test/patients/#{pipeline.patient.case_number}/pipelines/1/inputs/",
          outputs_dir: "test/patients/#{pipeline.patient.case_number}/pipelines/1/outputs/"
        }
      },
      included: [
        {
          "type": "computation",
          "attributes": {
            "status": "created",
            "error_message": nil,
            "exit_code": nil,
            "pipeline_step": "blood_flow_simulation",
            "revision": nil,
            "tag_or_branch": nil,
            "required_files": ["fluid_virtual_model", "ventricle_virtual_model"]
          }
        },
        {
          "type": "computation",
          "attributes": {
            "status": "created",
            "pipeline_step": "heart_model_calculation",
            "required_files": ["estimated_parameters"]
          }
        }
      ]
    )
  end
end
