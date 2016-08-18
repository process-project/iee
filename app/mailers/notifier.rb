# frozen_string_literal: true
class Notifier < ApplicationMailer
  def user_registered(user)
    @user = user
    @approve_url = account_confirmations_index_url
    to = User.supervisors.pluck(:email)

    if to.present?
      mail(to: to,
           subject: I18n.t('emails.approve_user.subject', name: user.name))
    end
  end

  def account_approved(user)
    mail(to: user.email, subject: I18n.t('emails.account_approved.subject'))
  end
end
