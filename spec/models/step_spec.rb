# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Step do
  context '#runnable?' do
    it 'returns true when no required files defined' do
      pipeline = create(:pipeline)
      step = Step.new('no-req-files')

      expect(step.input_present_for?(pipeline)).to be_truthy
    end

    it 'returns true if all requied files are present' do
      pipeline = create(:pipeline)
      project = pipeline.project

      create(:data_file,
             input_of: pipeline, data_type: :image,
             project: project)
      create(:data_file,
             input_of: pipeline, data_type: :segmentation_result,
             project: project)
      step = Step.new('req-files', [:image, :segmentation_result])

      expect(step.input_present_for?(pipeline)).to be_truthy
    end

    it 'returns false if any required file is missing' do
      pipeline = create(:pipeline)
      project = pipeline.project

      create(:data_file,
             input_of: pipeline, data_type: :image,
             project: project)
      step = Step.new('req-files', [:image, :segmentation_result])

      expect(step.input_present_for?(pipeline)).to be_falsy
    end
  end
end
