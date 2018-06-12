# frozen_string_literal: true

class Notifier < ApplicationMailer
  def user_registered(user)
    to = User.supervisors.pluck(:email)
    subject = I18n.t('emails.approve_user.subject', name: user.name)

    @user = user
    @approve_url = admin_users_url

    mail(to: to, subject: subject) if to.present?
  end

  def account_approved(user)
    mail(to: user.email, subject: I18n.t('emails.account_approved.subject'))
  end

  def audit_failed(ip)
    @ip = ip

    mail(to: ip.user.email, subject: I18n.t('emails.audit_failed.subject'))
  end

  def proxy_expired(user)
    @proxy = Proxy.new(user)
    mail(to: user.email, subject: I18n.t('emails.proxy_expired.subject'))
  end
end
