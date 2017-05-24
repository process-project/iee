# frozen_string_literal: true
require 'net/dav'

class PatientWebdav
  def initialize(user, options = {})
    @user = user
    @dav_client = options.fetch(:client) { create_dav_client }
  end

  protected

  def r_mkdir(path)
    elements = path.split('/')

    mkdir(elements[0])
    elements[1..-1].inject(elements[0]) do |p, el|
      "#{p}/#{el}".tap { |current_path| mkdir(current_path) }
    end
  end

  def mkdir(path)
    @dav_client.mkdir(path) unless @dav_client.exists?(path)
  end

  def delete(path)
    @dav_client.delete(path) if @dav_client.exists?(path)
  end

  private

  def create_dav_client
    Net::DAV.new(
      storage_url,
      headers: { 'Authorization' => "Bearer #{@user.try(:token)}" }
    )
  end

  def storage_url
    Rails.configuration.constants['file_store']['web_dav_base_url'] +
      Rails.configuration.constants['file_store']['web_dav_base_path'] +
      "/#{Rails.env}/patients/"
  end
end
