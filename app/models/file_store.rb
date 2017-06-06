# frozen_string_literal: true
# A pseudo-model class to hold some helper methods related to EurValve's FileStore
class FileStore
  def self.file_store_url
    file_store_config['web_dav_base_url']
  end

  def self.file_store_path
    file_store_config['web_dav_base_path']
  end

  def self.file_store_proxy_path
    file_store_url + file_store_config['web_dav_policy_proxy_path']
  end

  def self.file_store_js_path
    file_store_url + '/browser/browser.nocache.js'
  end

  def self.file_store_embed_js_path
    file_store_url + '/embed/embed.nocache.js'
  end

  def self.patients_path
    file_store_path + "/#{Rails.env}/patients/"
  end

  def self.file_store_config
    Rails.configuration.constants['file_store']
  end
end
