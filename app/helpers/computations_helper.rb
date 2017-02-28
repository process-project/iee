# frozen_string_literal: true
module ComputationsHelper
  include PatientsHelper

  def infrastructure_file_path(path)
    path.gsub('download/', 'download/prometheus/')
  end
end
