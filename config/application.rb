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
  end
end
