# frozen_string_literal: true
class FileStoreController < ApplicationController
  def index
    @user_email = current_user.email
    @user_groups = current_user.all_groups.map(&:name).to_s
    @token = current_user.token
    set_urls
  end

  private

  def set_urls
    @web_dav_base_url = web_dav_base_url
    @web_dav_base_href = Rails.configuration.constants['file_store']['web_dav_base_path']
    @web_dav_policy_proxy_url = web_dav_policy_proxy_url
  end

  def web_dav_base_url
    Rails.configuration.constants['file_store']['web_dav_base_url'] +
      Rails.configuration.constants['file_store']['web_dav_base_path']
  end

  def web_dav_policy_proxy_url
    Rails.configuration.constants['file_store']['web_dav_base_url'] +
      Rails.configuration.constants['file_store']['web_dav_policy_proxy_path']
  end
end
