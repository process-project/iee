# frozen_string_literal: true
source 'https://rubygems.org'

gem 'rails', '~> 5.0.0'

gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# javascript
gem 'animate-rails', '1.0.10'
gem 'coffee-rails', '~> 4.2'
gem 'gravtastic'
gem 'haml-rails'
gem 'icheck-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'nicescroll-rails'
gem 'select2-rails' # jquery replacement for select boxes
gem 'turbolinks', '~> 5.0'
gem 'zeroclipboard-rails' # copy text to clipboard

gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-sass', '~> 4.5'
gem 'simple_form'

# JSON validation
gem 'json-schema'

# Markdown
gem 'github-markup'
gem 'redcarpet'

gem 'devise', '~> 4.2.0'
gem 'jwt'
gem 'omniauth-openid'
gem 'pundit'

# Delayed jobs
gem 'clockwork'
gem 'sidekiq'

gem 'puma', '~> 3.0'

group :development, :test do
  gem 'bullet'
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'guard-rspec', require: false
  gem 'rspec-rails', '~> 3.0'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'

  # PLG OpenId requires ssh even for development
  # start app using `thin start --ssl
  gem 'thin'

  gem 'rubocop', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers'
end

group :production do
  gem 'newrelic_rpm'
  gem 'sentry-raven'
end
