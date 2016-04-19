module Rimrock
  class Service < ProxyService
    def initialize(computation, options = {})
      super(computation.user, rimrock_url, options)

      @computation = computation
      @user = computation.user
    end

    protected

    attr_reader :computation, :user

    private

    def rimrock_url
      Rails.application.config_for('eurvalve')['rimrock_url']
    end
  end

  class Exception < ::Exception
  end
end
