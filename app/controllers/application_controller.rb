# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Sentryable

  include Authenticate
  include Authorize
  include ForgeryProtection

  include ErrorRescues
end
