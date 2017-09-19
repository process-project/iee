# frozen_string_literal: true

require_relative '../config/boot'
require_relative '../config/environment'

module Clockwork
  every(Vapor::Application.config.clock.update, 'updating.computations') do
    TriggerUpdateJob.perform_later
  end
end
