# frozen_string_literal: true

Warden::Manager.after_set_user do |user, auth, opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = user.id
end

Warden::Manager.before_logout do |_user, auth, opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = nil
end

Warden::Manager.after_authentication do |user,auth,opts|
  Audits::Create.new(user).call auth.request.remote_ip,
                                auth.request.user_agent,
                                auth.request.env['HTTP_ACCEPT_LANGUAGE']

  Audits::PerformJob.perform_later user
end