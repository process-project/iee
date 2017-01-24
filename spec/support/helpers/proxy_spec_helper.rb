# frozen_string_literal: true
module ProxySpecHelper
  def outdated_proxy
    File.read(Rails.root.join('spec', 'support', 'proxy', 'outdated'))
  end
end
