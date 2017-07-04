# frozen_string_literal: true

module UsersHelper
  def user_name(user)
    safe_join([user.name,
               content_tag(:small, "(#{user.email})", class: 'light')])
  end

  def raw_user_name(user)
    "#{user.name} (#{user.email})"
  end
end
