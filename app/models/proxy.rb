# frozen_string_literal: true
class Proxy < OpenSSL::X509::Certificate
  def initialize(user)
    super(user.proxy)
  end

  def valid?
    not_after > Time.current
  end
end
