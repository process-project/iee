class FileStoreController < ApplicationController
  def index
    @token = current_user.token
    @web_dav_base_url = Rails.configuration.constants["file_store"]["web_dav_base_url"]
    @web_dav_base_href = Rails.configuration.constants["file_store"]["web_dav_base_href"]
  end
end