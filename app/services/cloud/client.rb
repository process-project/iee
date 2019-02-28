# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

require 'net/http'
require 'json'
require 'securerandom'

module Cloud
  class Client
    def initialize(user_token)
      if user_token.blank?
        Rails.logger.warn('Warning: blank user token passed to cloud client.')
      else
        @user_token = user_token
      end
      @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
      @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
      @template_id = Rails.configuration.constants['cloud']['computation_config_template']
    end
  end
end

# rubocop:enable Metrics/AbcSize
