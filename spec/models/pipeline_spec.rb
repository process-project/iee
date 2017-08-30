# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pipeline, type: :model do
  subject { create(:pipeline) }

  it { should belong_to(:patient) }
  it { should belong_to(:user) }
  it { should have_many(:computations).dependent(:destroy) }

  it 'generates relative pipeline id' do
    patient = create(:patient)

    p1 = create(:pipeline, patient: patient)
    p2 = create(:pipeline, patient: patient)

    expect(p1.iid).to eq(1)
    expect(p2.iid).to eq(2)
  end

  it 'returns pipeline working dir' do
    pipeline = build(:pipeline,
                     iid: 123,
                     patient: build(:patient, case_number: 'abc'))

    expect(pipeline.working_dir).to eq 'test/patients/abc/pipelines/123/'
  end

  it 'contains pipeline steps' do
    expect(described_class::STEPS).to contain_exactly(
      PipelineStep::Segmentation,
      PipelineStep::BloodFlowSimulation,
      PipelineStep::HeartModelCalculation
    )
  end

  it do
    should validate_inclusion_of(:pipeline_flow).
      in_array(%w[full_body_scan partial_body_scan something_else])
  end
end
