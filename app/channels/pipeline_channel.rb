# frozen_string_literal: true

class PipelineChannel < ApplicationCable::Channel
  def subscribed
    compuation = Computation.joins(:pipeline).
                 find_by(pipelines: { patient_id: params[:patient],
                                      iid: params[:pipeline] },
                         pipeline_step: params[:computation])

    stream_for compuation
  end
end
