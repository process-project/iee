# frozen_string_literal: true

class DataSetsController < ApplicationController
  DATA_SETS = %w[eurvalve inferred simulated eurvalveVirtual].freeze

  def show
    data_set = params[:id]
    if DATA_SETS.include?(data_set)
      @url = build_url(data_set)
    else
      raise ActionController::RoutingError, 'Dataset not found'
    end
  end

  private

  def build_url(data_set)
    uri = URI("#{site_url}?dataset=#{data_set}@eurvalve.shef.ac.uk")
    uri.query = URI.encode_www_form(
      URI.decode_www_form(uri.query || '') << ['access_token', current_user.token]
    )
    uri.to_s
  end

  def site_url
    Rails.configuration.constants['data_sets']['url'] +
      Rails.configuration.constants['data_sets']['site_path']
  end
end
