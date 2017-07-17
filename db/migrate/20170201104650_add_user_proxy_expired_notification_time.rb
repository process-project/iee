# frozen_string_literal: true

class AddUserProxyExpiredNotificationTime < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :proxy_expired_notification_time, :datetime
  end
end
