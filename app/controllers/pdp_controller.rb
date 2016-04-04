class PdpController < ActionController::Base
  include Pundit

  protect_from_forgery with: :null_session

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
