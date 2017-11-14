# frozen_string_literal: true

class Proxy < OpenSSL::X509::Certificate
  def initialize(user)
    super(user&.proxy)
    @valid = true
  rescue StandardError
    @valid = false
  end

  def valid?
    @valid && not_after > Time.current
  end
end
