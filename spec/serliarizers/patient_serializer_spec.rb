# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe PatientSerializer do
  it 'serializer basic patient data' do
    patient = build(:patient, case_number: 'patient123')

    json = JSON.parse(described_class.new(patient).serialized_json)

    expect(json).to include_json(
      data: {
        type: 'patient',
        id: 'patient123',
        attributes: { case_number: 'patient123' }
      }
    )
  end

  it 'serializer information about patient pipelines' do
    patient = create(:patient, case_number: 'patient123')
    p1, p2 = create_list(:pipeline, 2, patient: patient)

    json = JSON.parse(described_class.new(patient).serialized_json)

    expect(json).to include_json(
      data: {
        relationships: {
          pipelines: {
            data: [
              { id: p1.id.to_s, type: 'pipeline' },
              { id: p2.id.to_s, type: 'pipeline' }
            ]
          }
        }
      }
    )
  end
end
