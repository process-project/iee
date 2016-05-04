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
end
