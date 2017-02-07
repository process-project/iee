# frozen_string_literal: true
module ProxySpecHelper
  def outdated_proxy
    File.read(Rails.root.join('spec', 'support', 'proxy', 'outdated'))
  end

  def valid_proxy_time
    Time.zone.local(2017, 1, 17, 18, 0, 0)
  end
end
