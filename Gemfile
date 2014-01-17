source 'https://rubygems.org'

ruby "2.0.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use sqlite3 as the database for Active Record
#gem 'sqlite3', group: :development

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# including by github because bootstrap3 gem hasn't been published
# but bootstrap3 is the main branch on the repo (otherwise would
# need to specify branch: '3'
# https://github.com/thomas-mcdonald/bootstrap-sass/issues/428
gem 'bootstrap-sass', github: 'thomas-mcdonald/bootstrap-sass'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# use Steam OpenID omniauth gem for authenticating steam users
gem 'omniauth-steam'

# gem for managing environment variables (steam webapi key)
gem 'figaro'

# Heroku integration gem
gem 'rails_12factor', group: :production

# mongo
gem 'mongo'
gem 'bson_ext'

# gon - gets data from controller into view (as json)
# TODO: move match data to S3/Cloudfront
gem 'gon'

# unicorn http server
gem 'unicorn'

# gem for direct upload (user replays) to S3
gem 's3_direct_upload'

# http://railscasts.com/episodes/402-better-errors-railspanel?autoplay=true
group :development do
  gem 'debugger'
  gem 'better_errors'
  gem 'binding_of_caller'
#  gem 'meta_request'
end
