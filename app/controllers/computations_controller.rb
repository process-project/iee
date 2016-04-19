class ComputationsController < ApplicationController

  def create

  end

  private

  def create_params
    params.require(:patient_id)
  end
end