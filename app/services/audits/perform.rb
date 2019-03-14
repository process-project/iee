# frozen_string_literal: true

module Audits
  class Perform
    def initialize(user)
      @user = user
    end

    def call
      u_agent = @user.updated_agent
      Notifier.audit_failed(u_agent).deliver_later unless ok?(u_agent)
    end

    private

    def ok?(u_agent)
      return true if u_agent.nil?

      browser_ok?(u_agent) && ip_ok?(u_agent)
    end

    def browser_ok?(u_agent)
      return true if @user.devices.count < 2

      @user.devices.where(name: u_agent.name).count > 1
    end

    def ip_ok?(u_agent)
      return true if u_agent.ips.count < 2

      ip = u_agent.last_ip

      return true if u_agent.ips.where(address: ip.address).count > 1

      check_ips?(u_agent, ip)
    end

    def check_ips?(u_agent, ip)
      u_agent.ips.each do |i|
        return true if i.address != ip.address && i.cc == ip.cc
      end

      false
    end
  end
end
