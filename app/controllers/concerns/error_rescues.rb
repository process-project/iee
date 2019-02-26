# frozen_string_literal: true

module ErrorRescues
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do
      redirect_back fallback_location: root_path,
                    alert: I18n.t('record_not_found')
    end
  end
end
