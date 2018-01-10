# frozen_string_literal: true

module PipelineStep
  class PressureVolumeDisplay < RimrockBase
    STEP_NAME = 'pressure_volume_display'

    def initialize(computation, options = {})
      super(computation,
            'eurvalve/0dmodel',
            'pv_display.sh.erb',
            options)
    end

    def self.create(pipeline, params)
      PipelineSteps::Rimrock::Builder.new(pipeline, STEP_NAME, params).call
    end

    def runnable?
      pipeline.data_file(:data_series_1) &&
        pipeline.data_file(:data_series_2) &&
        pipeline.data_file(:data_series_3) &&
        pipeline.data_file(:data_series_4)
    end
  end
end
