# frozen_string_literal: true
class JwtToken
  def initialize(user)
    @user = user
  end

  def to_s
    JWT.encode(
      token_payload,
      Vapor::Application.config.jwt.key,
      Vapor::Application.config.jwt.key_algorithm
    )
  end

  def self.decode(token)
    JWT.decode(token, Vapor::Application.config.jwt.key, true,
               algorithm: Vapor::Application.config.jwt.key_algorithm)
  end

  private

  def token_payload
    {
      name: @user.name,
      email: @user.email,
      iss: Rails.configuration.jwt.issuer,
      exp: Time.now.to_i + Rails.configuration.jwt.expiration_time
    }
  end
end
