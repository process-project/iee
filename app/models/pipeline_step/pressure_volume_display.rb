# frozen_string_literal: true

module PipelineStep
  class PressureVolumeDisplay < RimrockBase
    DEF = RimrockStep.new('pressure_volume_display',
                          'eurvalve/0dmodel',
                          'pv_display.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:data_series_1) &&
        pipeline.data_file(:data_series_2) &&
        pipeline.data_file(:data_series_3) &&
        pipeline.data_file(:data_series_4)
    end
  end
end
