# frozen_string_literal: true
module ComputationsHelper
  include PatientsHelper

  def infrastructure_file_path(path)
    path&.gsub('download/', 'files/')
  end

  def run_status(computation)
    clazz = 'circle-o'
    additional_clazz = nil

    clazz, additional_clazz = runnable_run_status(computation) if computation.runnable?

    icon(clazz, class: additional_clazz)
  end

  private

  def runnable_run_status(computation)
    if computation.active?
      ['circle-o-notch', 'fa-spin']
    elsif computation.status == 'finished'
      ['check-circle-o', nil]
    elsif computation.status == 'error'
      ['times-circle-o', nil]
    else
      ['circle', nil]
    end
  end
end
