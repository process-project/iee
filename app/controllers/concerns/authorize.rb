# frozen_string_literal: true

module Authorize
  extend ActiveSupport::Concern

  included do
    include Pundit

    rescue_from Pundit::NotAuthorizedError do |exception|
      redirect_back fallback_location: root_path,
                    alert: not_authorized_msg(exception)
    end
  end

  private

  def not_authorized_msg(exception)
    policy_name = exception.policy.class.to_s.underscore

    I18n.t("#{policy_name}.#{exception.query}",
           scope: 'pundit', default: :default)
  end
end
