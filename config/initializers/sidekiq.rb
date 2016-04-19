sidekiq_connection = {
  url: Rails.application.config_for(:application)['redis_url']
}

Sidekiq.configure_server do |config|
  config.redis = sidekiq_connection
  config.average_scheduled_poll_interval = 1
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_connection
end
