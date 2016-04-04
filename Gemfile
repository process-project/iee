source 'https://rubygems.org'

gem 'dotenv-rails', :groups => [:development, :test]

gem 'rails', '4.2.6'
gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

# javascript
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'
gem 'haml-rails'
gem 'icheck-rails'
gem 'animate-rails', '1.0.10'
gem 'nicescroll-rails'

gem 'bootstrap-sass','~> 3.3'
gem 'font-awesome-sass','~> 4.5'
gem 'simple_form'

gem 'devise'
gem 'pundit'
gem 'omniauth-openid'

gem 'puma'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'quiet_assets'
  gem 'guard-rspec', require: false
end

group :development do
  gem 'web-console', '~> 2.0'
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

