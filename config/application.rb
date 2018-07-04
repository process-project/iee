# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

require File.expand_path('lib/jwt/config')

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Vapor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.,
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.middleware.insert_before Warden::Manager, Rack::Attack

    # Custom error pages
    config.exceptions_app = routes

    config.constants = config_for(:application)

    config.jwt = Jwt::Config.new(config.constants['jwt'])
    config.clock = Struct.new(:update).
                   new((config.constants['clock']['update'] || 30).seconds)

    # Used for parametrization of translations (PROCESS/EURVALVE)
    platform_type = config.constants['platform_type']

    if platform_type != 'eurvalve'
      config.i18n.load_path += Dir[Rails.root.join('config', 'locales', platform_type, '*.yml')]
    end

    redis_url_string = config.constants['redis_url']

    # Redis::Store does not handle Unix sockets well, so let's do it for them
    redis_config_hash = Redis::Store::Factory.
                        extract_host_options_from_uri(redis_url_string)
    redis_uri = URI.parse(redis_url_string)
    redis_config_hash[:path] = redis_uri.path if redis_uri.scheme == 'unix'

    redis_config_hash[:namespace] = 'cache:vapor'
    redis_config_hash[:expires_in] = 90.minutes # Cache should not grow forever
    config.cache_store = :redis_store, redis_config_hash
  end
end
