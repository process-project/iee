# frozen_string_literal: true
module Services
  class PoliciesController < ApplicationController
    before_action :load_service

    private

    def load_service
      @service = service_finder.find(params[:service_id])
      authorize(@service, :show?)
    end

    def service_finder
      Service
    end
  end
end
