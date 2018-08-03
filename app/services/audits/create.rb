# frozen_string_literal: true

module Audits
  class Create
    def initialize(user)
      @user = user
    end

    def call(ip, ua, lang)
      uao = UserAgent.find_or_create_by(name: ua) do |u|
        u.accept_language = lang
        u.user = @user
      end

      Ip.create(address: ip, user_agent: uao)
    end
  end
end
