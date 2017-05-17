# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Pipeline, type: :model do
  it 'generates relative pipeline id' do
    patient = create(:patient)

    p1 = create(:pipeline, patient: patient)
    p2 = create(:pipeline, patient: patient)

    expect(p1.iid).to eq(1)
    expect(p2.iid).to eq(2)
  end
end
