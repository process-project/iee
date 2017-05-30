# frozen_string_literal: true
require_relative '../config/boot'
require_relative '../config/environment'

module Clockwork
  every(1.minute, 'updating.computations') do
    TriggerUpdateJob.perform_later
  end
end
