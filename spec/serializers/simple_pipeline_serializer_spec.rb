# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe SimplePipelineSerializer do
  it 'serializes basic pipeline data' do
    pipeline = create(:pipeline, :with_computations, iid: 1, flow: 'unused_steps')

    json = JSON.parse(described_class.new(pipeline).serialized_json)

    expect(json).to include_json(
      data: {
        type: 'pipeline',
        id: pipeline.iid.to_s,
        attributes: {
          name: pipeline.name,
          flow: 'unused_steps'
        }
      }
    )
  end
end
