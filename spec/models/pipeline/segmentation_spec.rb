# frozen_string_literal: true
require 'rails_helper'
require 'models/pipeline/webdav_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe Pipeline::Segmentation do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, procedure_status: :imaging_uploaded) }

  before do
    allow(Webdav::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a Webdav-based step'

  it_behaves_like 'a pipeline step'

  it "runs the step only if patient's imaging is uploaded" do
    computation = Pipeline::Segmentation.new(patient, user).run
    expect(computation).to be_truthy
  end

  it "raise error if patient's imaging is not uploaded yet" do
    patient.not_started!
    expect { Pipeline::Segmentation.new(patient, user).run }.
      to raise_error('Patient imaging must be uploaded to run Segmentation')
  end
end
