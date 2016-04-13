module Api
  class PdpController < Api::ApplicationController
    skip_before_action :authenticate_user!

    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    def permit?
      current_user && resource && policy(resource).permit?(params[:permission])
    end

    def resource
      @resource ||= Resource.find_by(uri: params[:uri])
    end
  end
end
