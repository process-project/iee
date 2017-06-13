# frozen_string_literal: true
class DataSetsController < ApplicationController
  def index
    @url = build_url
  end

  private

  def build_url
    uri = URI(Rails.configuration.constants['data_sets']['url'])
    uri.query = URI.encode_www_form(
      URI.decode_www_form(uri.query || '') << ['access_token', current_user.token]
    )
    uri.to_s
  end
end
