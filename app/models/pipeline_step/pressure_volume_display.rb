# frozen_string_literal: true

module PipelineStep
  class PressureVolumeDisplay < Base
    DEF = RimrockStep.new('pressure_volume_display',
                          'eurvalve/0dmodel',
                          'pv_display.sh.erb',
                          [:data_series_1,
                           :data_series_2,
                           :data_series_3,
                           :data_series_4])

    def initialize(computation, options = {})
      super(computation, options)
    end

    def runnable?
      DEF.runnable_for?(computation)
    end

    protected

    def runner
      DEF.runner_for(computation, options)
    end
  end
end
