# frozen_string_literal: true

Gitlab.configure do |config|
  config.endpoint       = "https://#{ENV['GITLAB_HOST'] || 'gitlab.com'}/api/v4"
  config.private_token  = ENV['GITLAB_API_PRIVATE_TOKEN']

  puts ">>>>>>>>>>>>>>>> gitlab config endpoint: #{config.endpoint}"
end
