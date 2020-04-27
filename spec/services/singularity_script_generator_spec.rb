# frozen_string_literal: true

require 'rails_helper'

describe SingularityScriptGenerator do
  let(:singularity_pipeline) do
    create(:pipeline, flow: 'singularity_placeholder_pipeline')
  end

  let(:computation) do
    create(:singularity_computation,
           pipeline: singularity_pipeline,
           pipeline_step: 'singularity_placeholder_step',
           container_name: 'test_name',
           container_tag: 'test_tag',
           compute_site: computation.compute_site,
           parameter_values: { label1: 'w1', label2: 'w2', label3: 'w3' })
  end

  let(:wrong_computation) do
    create(:singularity_computation,
           pipeline: singularity_pipeline,
           pipeline_step: 'singularity_placeholder_step',
           container_name: 'test_name',
           container_tag: 'test_tag',
           compute_site: ComputeSite.where(name: :krk).first,
           parameter_values: { label1: 'w1', label2: 'w2' })
  end

  let!(:singularity_script_blueprint) do
    create(:singularity_script_blueprint,
           container_name: computation.container_name,
           container_tag: computation.container_tag,
           compute_site: computation.compute_site)
  end

  context 'given proper parameter_values' do
    it 'generates proper script' do
      generated_script = described_class.new(computation).call

      expect(generated_script).to include 'w1'
      expect(generated_script).to include 'w2'
      expect(generated_script).to include 'w3'
    end
  end

  context 'given not enough parameter_values' do
    it 'raises KeyError' do
      expect { described_class.new(wrong_computation).call }. to raise_error(KeyError)
    end
  end
end
