# frozen_string_literal: true

module Audits
  class Perform

    def initialize(user)
      @user = user
    end

    def call
      puts "[DEBUG][Audit::Perform] call() for #{@user.email}"

      Notifier.audit_failed(@user.last_ip).deliver_later unless ok?
    end

    private

    def ok?
      browser_ok? && ip_ok?
    end

    def browser_ok?
      return true if @user.user_agents.count < 2

      @user.user_agents.where(name: @user.last_agent.name).count > 1
    end

    def ip_ok?
      return true if @user.ips.count < 2

      return true if @user.ips.where(address: @user.last_ip.address).count > 1

      @user.ips.each do |ip|
        return true if ip.address != @user.last_ip.address and ip.cc == @user.last_ip.cc
      end

      false
    end
  end
end