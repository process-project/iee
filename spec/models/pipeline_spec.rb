# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pipeline, type: :model do
  subject { create(:pipeline) }

  it { should belong_to(:project) }
  it { should belong_to(:user) }
  it { should have_many(:computations).dependent(:destroy) }

  it 'generates relative pipeline id' do
    project = create(:project)

    p1 = create(:pipeline, project: project)
    p2 = create(:pipeline, project: project)

    expect(p1.iid).to eq(1)
    expect(p2.iid).to eq(2)
  end

  it 'returns pipeline working dir' do
    pipeline = build(:pipeline,
                     iid: 123,
                     project: build(:project, project_name: 'abc'))

    expect(pipeline.inputs_dir).to eq 'test/projects/abc/pipelines/123/inputs/'
    expect(pipeline.outputs_dir).to eq 'test/projects/abc/pipelines/123/outputs/'
  end

  it do
    should validate_inclusion_of(:flow).
      in_array(Flow.types.map(&:to_s))
  end

  context 'pipeline status' do
    it 'is success when all steps are completed with success' do
      pipeline = create(:pipeline)
      create_list(:computation, 2,
                  status: :finished, pipeline: pipeline,
                  pipeline_step: 'placeholder_step')

      expect(pipeline.status).to eq :success
    end

    it 'is error when any step finished with error' do
      pipeline = create(:pipeline)
      create(:computation,
             status: :finished, pipeline: pipeline,
             pipeline_step: 'placeholder_step')
      create(:computation,
             status: :error, pipeline: pipeline,
             pipeline_step: 'placeholder_step')

      expect(pipeline.status).to eq :error
    end

    it 'is running when any step is running' do
      pipeline = create(:pipeline)
      create(:computation,
             status: :finished, pipeline: pipeline,
             pipeline_step: 'placeholder_step')

      running = create(:computation,
                       status: :running, pipeline: pipeline,
                       pipeline_step: 'placeholder_step')
      expect(pipeline.status).to eq :running

      running.update_attributes(status: :new)
      expect(pipeline.status).to eq :running

      running.update_attributes(status: :queued)
      expect(pipeline.status).to eq :running
    end

    it 'is waiting when is not running and any step is waiting for input' do
      pipeline = create(:pipeline, flow: :placeholder_pipeline)
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
