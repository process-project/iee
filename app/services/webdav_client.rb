# frozen_string_literal: true

require 'net/dav'

class WebdavClient
  def initialize(url, options = {})
    parse_params(url, options)
    validate_auth_options
    init_dav_client
  end

  def get_file(remote_path, local_filename)
    raise(ArgumentError, "File: #{local_filename} already exists.") if File.exist?(local_filename)

    File.open(local_filename, mode: 'w', encoding: 'ASCII-8BIT') do |file|
      @dav_client.get(remote_path) { |s| file.write(s) }
    end
  end

  def put_file(local_filename, remote_path)
    File.open(local_filename, 'r') do |file|
      @dav_client.put(remote_path, file, File.size(local_filename))
    end
  end

  private

  def method_missing(method, *args, &block)
    if @dav_client.respond_to?(method)
      @dav_client.send(method, *args, &block)
    else
      super.method_missing(method, *args, &block)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @dav_client.respond_to?(method_name, include_private)
  end

  protected

  def parse_params(url, options)
    @url = url
    dav_options = options.dup
    @verify_server = dav_options.delete(:verify_server) { true }
    @username = dav_options.delete(:username)
    @password = dav_options.delete(:password)
    @dav_options = dav_options
  end

  def validate_auth_options
    return if jwt_auth_enabled? ^ basic_auth_enabled?
    raise(ArgumentError, 'Provide either a :token or :user and :password')
  end

  def jwt_auth_enabled?
    @dav_options.include?(:headers) && @dav_options[:headers]['Authorization'].start_with?('Bearer')
  end

  def basic_auth_enabled?
    @username && @password
  end

  def init_dav_client
    @dav_client = Net::DAV.new(@url, @dav_options)
    @dav_client.credentials(@username, @password) if basic_auth_enabled?
    @dav_client.verify_server = @verify_server
  end
end
