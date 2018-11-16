# frozen_string_literal: true

module Audits
  class Perform
    def initialize(user)
      @user = user
    end

    def call
      ua = @user.updated_agent
      Notifier.audit_failed(ua).deliver_later unless ok?(ua)
    end

    private

    def ok?(ua)
      return true if ua.nil?

      browser_ok?(ua) && ip_ok?(ua)
    end

    def browser_ok?(ua)
      return true if @user.devices.count < 2

      @user.devices.where(name: ua.name).count > 1
    end

    def ip_ok?(ua)
      return true if ua.ips.count < 2

      ip = ua.updated_ip

      return true if ua.ips.where(address: ip.address).count > 1

      check_ips?(ua, ip)
    end

    def check_ips?(ua, ip)
      ua.ips.each do |i|
        return true if i.address != ip.address && i.cc == ip.cc
      end

      false
    end
  end
end
