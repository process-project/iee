module Api
  class PdpController < Api::ApplicationController
    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    def permit?
      current_user && resource && policy(resource).permit?(params[:permission])
    end

    def resource
      @resource ||= Resource.where(":uri ~ uri", uri: params[:uri]).first
    end
  end
end
