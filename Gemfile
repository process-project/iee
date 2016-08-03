source 'https://rubygems.org'

gem 'rails', '~> 5.0.0'
gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

# javascript
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks', '~> 5.0'
gem 'haml-rails'
gem 'icheck-rails'
gem 'animate-rails', '1.0.10'
gem 'nicescroll-rails'
gem 'gravtastic'
gem 'zeroclipboard-rails' # copy text to clipboard

gem 'bootstrap-sass','~> 3.3'
gem 'font-awesome-sass','~> 4.5'
gem 'simple_form'

# Markdown
gem 'redcarpet'
gem 'github-markup'

gem 'devise', '~> 4.2.0'
gem 'pundit'
gem 'omniauth-openid'
gem 'jwt'

# Delayed jobs
gem 'sidekiq'
gem 'sinatra', require: false, github: 'sinatra'
gem 'clockwork'

gem 'puma', '~> 3.0'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.0'
  gem 'guard-rspec', require: false
  gem 'dotenv-rails'
end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # PLG OpenId requires ssh even for development
  # start app using `thin start --ssl
  gem 'thin'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'faker'
end

group :production do
  gem 'sentry-raven'
  gem 'newrelic_rpm'
end
