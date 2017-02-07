# frozen_string_literal: true
class GuardedProxyExecutor
  def initialize(user)
    @user = user
  end

  def call
    proxy.valid? ? block_given? && yield : report_problem
  end

  private

  def proxy
    Proxy.new(@user)
  end

  def report_problem
    return unless notify_user?

    Notifier.proxy_expired(@user).deliver_later
    @user.update_attribute(:proxy_expired_notification_time, Time.zone.now)
  end

  def notify_user?
    @user.proxy_expired_notification_time.blank? ||
      @user.proxy_expired_notification_time < 1.day.ago
  end
end
