# frozen_string_literal: true

module Audits
  class Create
    def initialize(user)
      @user = user
    end

    def call(ip, user_agent, lang)
      dev = Device.find_or_create_by(name: user_agent, user: @user) do |u|
        u.accept_language = lang
      end

      Ip.create(address: ip, device: dev)
    end
  end
end
