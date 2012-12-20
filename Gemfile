source 'https://rubygems.org'

gem 'rails', '3.2.9'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem "devise"
gem 'omniauth'
gem 'omniauth-twitter'
#gem "bootstrap-sass"
gem "twitter-bootstrap-rails"
gem "haml-rails"
gem "kaminari"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
gem 'capistrano', :require => nil
gem 'capistrano-ext', :require => nil
gem 'capistrano_colors', :require => nil

# To use debugger
# gem 'debugger'

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "capybara"
end

group :production do
  gem "unicorn"
end
