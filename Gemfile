source 'https://rubygems.org'

gem 'dotenv-rails', :groups => [:development, :test]

gem 'rails', '5.0.0'
gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

# Element still used in vapor but deprecated in rails 5
gem 'rails-controller-testing'

# javascript
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'
gem 'haml-rails'
gem 'icheck-rails'
gem 'animate-rails', '1.0.10'
gem 'nicescroll-rails'
gem 'gravtastic'

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

gem 'puma'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'guard-rspec', require: false
end

group :development do
  gem 'web-console', '~> 3.0'
  gem 'spring'

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
