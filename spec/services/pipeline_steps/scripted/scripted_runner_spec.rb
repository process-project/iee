# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Scripted::ScriptedRunner do
  include ActiveSupport::Testing::TimeHelpers
  let(:template_fetcher) do
    fetcher = class_double(Gitlab::GetFile)
    allow(fetcher).to receive(:new).
      with('repo', 'file', anything).
      and_return(double(call: 'script payload'))

    fetcher
  end

  let(:revision_fetcher) do
    fetcher = class_double(Gitlab::Revision)
    allow(fetcher).to receive_message_chain(:new, :call) { 'revision' }

    fetcher
  end

  let(:updater) { instance_double(ComputationUpdater, call: true) }

  let(:cluster_computation) do
    create(:scripted_computation, pipeline_step: '0d_models', deployment: 'cluster')
  end

  let(:cloud_computation) do
    create(:scripted_computation, pipeline_step: '0d_models', deployment: 'cloud')
  end

  subject do
    case @deployment
    when 'cloud'
      described_class.new(cloud_computation, 'repo', 'file',
                          template_fetcher: template_fetcher,
                          revision_fetcher: revision_fetcher,
                          updater: double(new: updater))
    else
      described_class.new(cluster_computation, 'repo', 'file',
                          template_fetcher: template_fetcher,
                          revision_fetcher: revision_fetcher,
                          updater: double(new: updater))
    end
  end

  it 'sets cluster computation start time to now' do
    @deployment = 'cluster'
    now = Time.zone.local(2017, 1, 2, 7, 21, 34)
    travel_to now do
      subject.call

      expect(subject.computation.started_at).to eq now
    end
  end

  it 'sets cloud computation start time to now' do
    @deployment = 'cloud'
    cloud_start_double
    now = Time.zone.local(2017, 1, 2, 7, 21, 34)
    travel_to now do
      subject.call

      expect(subject.computation.started_at).to eq now
    end
  end

  it 'sends notification after cluster computation is started' do
    @deployment = 'cluster'
    expect(updater).to receive(:call)

    subject.call
  end

  it 'sends notification after cloud computation is started' do
    @deployment = 'cloud'
    cloud_start_double
    expect(updater).to receive(:call)

    subject.call
  end

  it 'changes cluster computation status to :new' do
    @deployment = 'cluster'
    subject.call

    expect(subject.computation.status).to eq 'new'
  end

  it 'changes cloud computation status to :queued' do
    @deployment = 'cloud'
    cloud_start_double
    subject.call

    expect(subject.computation.status).to eq 'queued'
  end

  context 'inputs are available' do
    before do
      create(:data_file,
             patient: cluster_computation.pipeline.patient,
             data_type: :parameter_optimization_result)
      create(:data_file,
             patient: cloud_computation.pipeline.patient,
             data_type: :parameter_optimization_result)
    end

    it 'starts a Rimrock job for cluster computation' do
      @deployment = 'cluster'
      expect(Rimrock::StartJob).to receive(:perform_later)

      subject.call
    end

    it 'submits a cloud request for cloud computation' do
      @deployment = 'cloud'
      client = cloud_start_double
      expect(client).to receive(:call)
      subject.call
    end

    it 'creates cluster computation with script returned by generator' do
      @deployment = 'cluster'
      cluster_computation.assign_attributes(revision: 'revision')

      subject.call

      expect(cluster_computation.script).to include 'script payload'
    end

    it 'creates cloud computation with script returned by generator' do
      @deployment = 'cloud'
      cloud_start_double
      cloud_computation.assign_attributes(revision: 'revision')
      subject.call
      expect(cloud_computation.script).to include 'script payload'
    end

    it 'set job_id to null while restarting cluster computation' do
      @deployment = 'cluster'
      cluster_computation.update_attributes(job_id: 'some_id', revision: 'master')

      subject.call

      expect(cluster_computation.job_id).to be_nil
    end
  end

  private

  def cloud_start_double
    start = double(Cloud::Start)
    allow(Cloud::Start).to receive(:new).and_return(start)
    allow(start).to receive_messages(call: 1)
    start
  end

  def cloud_client_double
    client = double(Cloud::Client)
    allow(Cloud::Client).to receive(:new).and_return(client)
    allow(client).to receive_messages(
      spawn_appliance_set: 1, spawn_appliance: 2
    )
    client
  end
end
