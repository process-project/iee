# frozen_string_literal: true

class JwtToken
  def initialize(user)
    @user = user
  end

  def generate(expiration_time_in_seconds = nil)
    JWT.encode(
      token_payload(expiration_time_in_seconds),
      Vapor::Application.config.jwt.key,
      Vapor::Application.config.jwt.key_algorithm,
      header_fields = {typ: 'JWT'}
    )
  end

  def self.decode(token)
    JWT.decode(token, Vapor::Application.config.jwt.key, true,
               algorithm: Vapor::Application.config.jwt.key_algorithm)
  end

  private

  def token_payload(expiration_time_in_seconds)
    {
      name: @user.name,
      email: @user.email,
      sub: @user.id.to_s,
      iss: Rails.configuration.jwt.issuer,
      iat: Time.now.to_i,
      nbf: Time.now.to_i - 1,
      exp: Time.now.to_i + (expiration_time_in_seconds ||
             Rails.configuration.jwt.expiration_time)
    }
  end
end
