# frozen_string_literal: true

require 'rails_helper'

describe Pipelines::Create do
  let(:user) { create(:user) }
  let(:webdav) { instance_double(Webdav::Client) }

  before { allow(webdav).to receive(:r_mkdir) }

  it 'creates new pipeline in db' do
    expect { described_class.new(build(:pipeline, user: user), {}, client: webdav).call }.
      to change { Pipeline.count }.by(1)
  end

  it 'pass step version into rimrock based computations' do
    pipeline = build(:pipeline, user: user)
    config = Hash[step_names(pipeline.flow.to_sym).map { |n| [n, { tag_or_branch: "#{n}-v1" }] }]

    described_class.new(pipeline, config, client: webdav).call

    rimrock_step = pipeline.computations.find_by(type: 'RimrockComputation')

    expect(rimrock_step.tag_or_branch).to eq("#{rimrock_step.pipeline_step}-v1")
  end

  it 'creates pipeline webdav directory' do
    patient = create(:patient)
    new_pipeline = build(:pipeline, patient: patient, user: user)

    expect(webdav).to receive(:r_mkdir).
      with("test/patients/#{patient.case_number}/pipelines/1/")

    described_class.new(new_pipeline, {}, client: webdav).call
  end

  it 'don\'t create db pipeline when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception

    expect do
      described_class.new(build(:pipeline, user: user), {}, client: webdav).call
    end.to_not(change { Pipeline.count })
  end

  it 'set error message when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception
    new_pipeline = build(:pipeline, user: user)

    described_class.new(new_pipeline, client: webdav).call

    expect(new_pipeline.errors[:name]).
      to include(I18n.t('activerecord.errors.models.pipeline.create_dav403'))
  end

  it 'creates computations for all pipeline steps' do
    pipeline = described_class.new(build(:pipeline, user: user), {}, client: webdav).call

    expect(pipeline.computations.count).to eq Pipeline::FLOWS[pipeline.flow.to_sym].size
    expect(pipeline.computations.where(pipeline_step: step_names(pipeline.flow.to_sym)).count).
      to eq Pipeline::FLOWS[pipeline.flow.to_sym].size
  end

  private

  def web_dav_with_http_server_exception
    webdav.tap do |webdav|
      allow(webdav).to receive(:r_mkdir).
        and_raise(Net::HTTPServerException.new(403, 'Error'))
    end
  end

  def step_names(fl)
    Pipeline::FLOWS[fl].map { |c| c::STEP_NAME }
  end
end
