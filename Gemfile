# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.1.0'

gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# javascript
gem 'animate-rails', '1.0.10'
gem 'clipboard-rails' # copy text to clipboard
gem 'coffee-rails', '~> 4.2'
gem 'gravtastic'
gem 'haml-rails'
gem 'icheck-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'nicescroll-rails'
gem 'select2-rails' # jquery replacement for select boxes
gem 'turbolinks', '~> 5.0'

gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-sass', '~> 4.5'
gem 'simple_form'

# app security
gem 'rack-attack'

# JSON validation
gem 'json-schema'

# Markdown
gem 'github-markup'
gem 'redcarpet'

gem 'devise', '~> 4.3.0'
gem 'jwt'
gem 'omniauth-openid'
gem 'pundit'

# Files store client
gem 'net_dav'

# Delayed jobs
gem 'clockwork'
gem 'sidekiq', '< 6'

# Cache store
gem 'redis-rails'

# File processing
gem 'rubyzip', '>= 1.0.0'

# Gitlab integration
gem 'gitlab'

gem 'puma', '~> 3.7'

group :development, :test do
  gem 'bullet'
  gem 'byebug', platform: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'guard-rspec', require: false
  gem 'rspec-rails', '~> 3.0'
end

group :development do
  gem 'brakeman', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # PLG OpenId requires ssh even for development
  # start app using `thin start --ssl
  gem 'thin'

  gem 'rubocop', '0.51.0', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers'
end

group :production do
  gem 'newrelic_rpm'
  gem 'sentry-raven'
end
