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

    expect(pipeline.inputs_dir).to eq 'test/patients/abc/pipelines/123/inputs/'
    expect(pipeline.outputs_dir).to eq 'test/patients/abc/pipelines/123/outputs/'
  end

  it do
    should validate_inclusion_of(:flow).
      in_array(Flow.types.map(&:to_s))
  end

  it 'returns data file scoped into pipeline' do
    patient = create(:patient)
    p1, p2 = create_list(:pipeline, 2, patient: patient)

    create(:data_file,
           patient: patient, output_of: p1,
           data_type: :image, name: 'p1 image output')
    create(:data_file,
           patient: patient, output_of: p2,
           data_type: :image, name: 'p2 image output')
    create(:data_file,
           patient: patient, input_of: p1,
           data_type: :off_mesh, name: 'p1 off mesh output')
    create(:data_file,
           patient: patient, input_of: p2,
           data_type: :graphics, name: 'p2 graphics output')
    create(:data_file,
           patient: patient,
           data_type: :estimated_parameters, name: 'input')

    expect(p1.data_file(:image).name).to eq('p1 image output')
    expect(p2.data_file(:image).name).to eq('p2 image output')
    expect(p2.data_file(:off_mesh)).to be_nil
    expect(p2.data_file(:graphics).name).to eq('p2 graphics output')
    expect(p1.data_file(:estimated_parameters).name).to eq('input')
    expect(p2.data_file(:estimated_parameters).name).to eq('input')
  end

  context 'data files order' do
    it 'returns first data file from output directory' do
      patient = create(:patient)
      pipeline = create(:pipeline, patient: patient)

      create(:data_file,
             patient: patient,
             data_type: :image, name: 'patient file')
      create(:data_file,
             patient: patient,
             input_of: pipeline,
             data_type: :image, name: 'pipeline input file')
      create(:data_file,
             patient: patient,
             output_of: pipeline,
             data_type: :image, name: 'pipeline output file')

      expect(pipeline.data_file(:image).name).to eq('pipeline output file')
    end

    it 'returns pipeline input data file when no output' do
      patient = create(:patient)
      pipeline = create(:pipeline, patient: patient)

      create(:data_file,
             patient: patient,
             data_type: :image, name: 'patient file')
      create(:data_file,
             patient: patient,
             input_of: pipeline,
             data_type: :image, name: 'pipeline input file')

      expect(pipeline.data_file(:image).name).to eq('pipeline input file')
    end

    it 'returns patient input files when no pipeline output or input' do
      patient = create(:patient)
      pipeline = create(:pipeline, patient: patient)

      create(:data_file,
             patient: patient,
             data_type: :image, name: 'patient file')

      expect(pipeline.data_file(:image).name).to eq('patient file')
    end
  end

  context 'pipeline status' do
    it 'is success when all steps are completed with success' do
      pipeline = create(:pipeline)
      create_list(:computation, 2,
                  status: :finished, pipeline: pipeline,
                  pipeline_step: 'ageing_model_x2')

      expect(pipeline.status).to eq :success
    end

    it 'is error when any step finished with error' do
      pipeline = create(:pipeline)
      create(:computation,
             status: :finished, pipeline: pipeline,
             pipeline_step: 'ageing_model_x2')
      create(:computation,
             status: :error, pipeline: pipeline,
             pipeline_step: 'ageing_model_x2')

      expect(pipeline.status).to eq :error
    end

    it 'is running when any step is running' do
      pipeline = create(:pipeline)
      create(:computation,
             status: :finished, pipeline: pipeline,
             pipeline_step: 'ageing_model_x2')

      running = create(:computation,
                       status: :running, pipeline: pipeline,
                       pipeline_step: 'ageing_model_x2')
      expect(pipeline.status).to eq :running

      running.update_attributes(status: :new)
      expect(pipeline.status).to eq :running

      running.update_attributes(status: :queued)
      expect(pipeline.status).to eq :running
    end

    it 'is waiting when is not running and any step is waiting for input' do
      pipeline = create(:pipeline, flow: :avr_surgical_preparation)
      create(:computation,
             status: :created, pipeline: pipeline,
             pipeline_step: 'rom')

      expect(pipeline.status).to eq :waiting
    end
  end

  context 'pipeline creator' do
    it 'returns creator name' do
      user = create(:user, first_name: 'John', last_name: 'Rambo')
      pipeline = create(:pipeline, user: user)

      expect(pipeline.owner_name).to eq('John Rambo')
    end

    it 'returns information about deleted user when owner is nil' do
      user = create(:user, first_name: 'John', last_name: 'Rambo')
      pipeline = create(:pipeline, user: user)
      user.destroy!
      pipeline.reload

      expect(pipeline.owner_name).to eq('(deleted user)')
    end
  end
end
