# frozen_string_literal: true
module ProxyHelper
  def require_new_proxy?
    current_user &&
      (current_user.proxy.blank? || !Proxy.new(current_user).valid?) &&
      Computation.active.where(user: current_user).count.positive?
  end
end
