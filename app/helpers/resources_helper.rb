# frozen_string_literal: true
module ResourcesHelper
  def resource
    @resource ||= Resource.new
  end
end
