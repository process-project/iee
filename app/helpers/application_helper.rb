# frozen_string_literal: true
module ApplicationHelper
  include HamlHelper

  def supervisor?
    controller.current_user&.groups&.where(name: 'supervisor')&.exists?
  end
end
