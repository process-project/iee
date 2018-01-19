# frozen_string_literal: true

module PipelineStep
  class PressureVolumeDisplay < RimrockBase
    DEF = RimrockStep.new('pressure_volume_display',
                          'eurvalve/0dmodel',
                          'pv_display.sh.erb',
                          [:data_series_1,
                           :data_series_2,
                           :data_series_3,
                           :data_series_4])

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      DEF.runnable_for?(computation)
    end
  end
end
