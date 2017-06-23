# frozen_string_literal: true
module ProxyHelper
  def require_new_proxy?
    !Proxy.new(current_user).valid? &&
      Computation.active.rimrock.where(user: current_user).count.positive?
  end

  def proxy_valid?
    Proxy.new(current_user).valid?
  end
end
