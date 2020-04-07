# frozen_string_literal: true

source 'https://rubygems.org'

/(?<ruby_engine>.*)-(?<engine_version>.*)/ =~ File.read('.ruby-version').strip

ruby ruby_engine == 'ruby' ? engine_version : '~>2.3', engine: ruby_engine, engine_version: engine_version

gem 'rails', '~>5.2.0'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'therubyrhino'
end

platform :ruby do
  gem 'mini_racer'
  gem 'pg'
end

gem 'bootsnap'
gem 'bootstrap'
gem 'bootstrap_form'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'puma'
gem 'rails-controller-testing'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end

group :test do
  gem 'minitest-reporters'
end

group :production do
  gem 'rails_12factor'
end
