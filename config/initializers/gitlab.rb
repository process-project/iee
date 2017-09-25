# frozen_string_literal: true

Gitlab.configure do |config|
  config.endpoint       = ENV['GITLAB_ENDPOINT'] || 'https://gitlab.com/api/v4'
  config.private_token  = ENV['GITLAB_API_PRIVATE_TOKEN']
end
