# frozen_string_literal: true

module PipelineStep
  class Segmentation < PipelineStep::Base
    DEF = WebdavStep.new('segmentation', [:image])

    def initialize(computation, options = {})
      super(computation, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      DEF.runnable_for?(computation)
    end

    protected

    def internal_run
      computation.tap do |c|
        c.update_attributes(input_path: image_data_file.path)
        Webdav::StartJob.perform_later(c)
      end
    end

    private

    def image_data_file
      pipeline.data_file(:image)
    end

    def input_path
      File.join(@patient.working_dir, "imaging_#{@patient.case_number}.zip")
    end
  end
end
