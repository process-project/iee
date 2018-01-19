# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Step do
  context '#runnable?' do
    it 'returns true when no required files defined' do
      computation = create(:computation)
      step = Step.new('no-req-files')

      expect(step.runnable_for?(computation)).to be_truthy
    end

    it 'returns true if all requied files are present' do
      computation = create(:computation)
      pipeline = computation.pipeline
      patient = pipeline.patient

      create(:data_file,
             input_of: pipeline, data_type: :image,
             patient: patient)
      create(:data_file,
             input_of: pipeline, data_type: :segmentation_result,
             patient: patient)
      step = Step.new('req-files', [:image, :segmentation_result])

      expect(step.runnable_for?(computation)).to be_truthy
    end

    it 'returns false if any required file is missing' do
      computation = create(:computation)
      pipeline = computation.pipeline
      patient = pipeline.patient

      create(:data_file,
             input_of: pipeline, data_type: :image,
             patient: patient)
      step = Step.new('req-files', [:image, :segmentation_result])

      expect(step.runnable_for?(computation)).to be_falsy
    end
  end
end
