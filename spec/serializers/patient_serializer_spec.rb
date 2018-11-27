# frozen_string_literal: true

require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe PatientSerializer do
  it 'serializes basic patient data' do
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
end
