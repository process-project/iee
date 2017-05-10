# frozen_string_literal: true

require 'net/dav'

class WebdavClient
  def initialize(url, options = {})
    @verify_server = options.delete(:verify_server)
    @options = options
    validate_auth_options

    @dav_client = Net::DAV.new(
      url,
      @options
    )
    @dav_client.verify_server = @verify_server if @verify_server
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

  def validate_auth_options
    return if jwt_auth_enabled? ^ basic_auth_enabled?
    raise(ArgumentError, 'Provide either a :token or :user and :password')
  end

  def jwt_auth_enabled?
    @options.include?(:headers) && @options[:headers]['Authorization'].start_with?('Bearer')
  end

  def basic_auth_enabled?
    @options.include?(:username) && @options.include?(:password)
  end
end
