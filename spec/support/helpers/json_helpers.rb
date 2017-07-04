# frozen_string_literal: true

module JsonHelpers
  def response_json
    JSON.parse(response.body)
  end
end
