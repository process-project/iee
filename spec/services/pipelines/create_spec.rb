# frozen_string_literal: true

require 'rails_helper'

describe Pipelines::Create do
  let(:user) { create(:user) }

  it 'creates new pipeline in db' do
    expect { described_class.new(build(:pipeline, user: user), {}).call }.
      to change { Pipeline.count }.by(1)
  end

  it 'pass step version into rimrock based computations' do
    pipeline = build(:pipeline, user: user)
    config = Hash[step_names(pipeline).map { |n| [n, { tag_or_branch: "#{n}-v1" }] }]

    described_class.new(pipeline, config).call

    rimrock_step = pipeline.computations.find_by(type: 'RimrockComputation')

    expect(rimrock_step.tag_or_branch).to eq("#{rimrock_step.pipeline_step}-v1")
  end

  it 'creates computations for all pipeline steps' do
    pipeline = described_class.new(build(:pipeline, user: user), {}).call

    expect(pipeline.computations.count).to eq pipeline.steps.size
    expect(pipeline.computations.where(pipeline_step: step_names(pipeline)).count).
      to eq pipeline.steps.size
  end

  private

  def step_names(pipeline)
    pipeline.steps.map(&:name)
  end
end
