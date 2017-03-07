source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Font awesome fonts
gem "font-awesome-sass"

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'

# simplest way to group temporal data
gem 'groupdate'

# DSL for forms
gem 'simple_form'

# Pagination
gem 'kaminari'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Detect browser agent
gem 'browser'

# SLIM templates
gem 'slim-rails'

# User auth
gem "sorcery", git: "https://github.com/NoamB/sorcery.git"

# Authorization
gem "pundit"

# Decorators <3
gem 'draper'

# Good model abstraction
gem 'virtus'

# Postgres
gem 'pg'

# Serializers for models
gem 'active_model_serializers'

# CSS Mixings
gem 'bourbon'

# Bootstrap
gem 'bootstrap-sass', '~> 3.3.6'

# Rack Middleware for handling Cross-Origin Resource Sharing (CORS)
gem 'rack-cors', :require => 'rack/cors'

# Nicer console
gem 'pry-rails'

# Deploy
gem 'capistrano', '~> 3.1'
gem 'capistrano-bundler', '~> 1.1.4'
gem 'capistrano-rails', '~> 1.1.3'
gem 'capistrano-rbenv', github: "capistrano/rbenv"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem "minitest-rails"
  gem 'fabrication-rails'
  gem 'faker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'

  gem 'better_errors'
  gem 'quiet_assets'

end

group :test do
  gem "webmock"
  gem 'minispec-metadata'
  gem 'shoulda'
  gem 'database_cleaner'
  gem 'mocha'
  gem 'guard'
  gem 'guard-minitest'

end
