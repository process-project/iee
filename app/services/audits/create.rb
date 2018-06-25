# frozen_string_literal: true

module Audits
  class Create
    def initialize(user)
      @user = user
    end

    def call(ip, ua, lang)
      Ip.create(address: ip, user: @user)
      UserAgent.create(name: ua, accept_language: lang, user: @user)
    end
  end
end