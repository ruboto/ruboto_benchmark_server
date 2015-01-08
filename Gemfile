source 'https://rubygems.org'

ruby '1.9.3', engine: 'jruby', engine_version: '1.7.18'

gem 'rails', '4.1.8'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'therubyrhino'
end

platform :ruby do
  # gem 'pg'
  gem 'sqlite3'
  gem 'therubyracer'
end

gem 'coffee-rails', '~> 4.0.0'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'puma'
gem 'sass-rails', '~> 4.0.3'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :test do
  gem 'minitest-reporters'
end

group :production do
  gem 'rails_12factor'
end
