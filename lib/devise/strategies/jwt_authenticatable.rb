# frozen_string_literal: true

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class JwtAuthenticatable < Authenticatable
      def valid?
        super || token && request.fullpath.starts_with?('/api')
      end

      def authenticate!
        resource = User.from_token(token)
        resource ? success!(resource) : fail(:invalid_credentials)
      rescue StandardError
        fail(:invalid_credentials)
      end

      private

      def token
        @token ||= bearer_token
      end

      def bearer_token
        pattern = /^Bearer /
        header  = request.env['HTTP_AUTHORIZATION']
        header.gsub(pattern, '') if header&.match(pattern)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Devise::Strategies::JwtAuthenticatable)
