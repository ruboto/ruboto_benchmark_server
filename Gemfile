# frozen_string_literal: true

source 'https://rubygems.org'

/(?<ruby_engine>.*)-(?<engine_version>.*)/ =~ File.read('.ruby-version').strip

ruby ruby_engine == 'ruby' ? engine_version : '~>2.3', engine: ruby_engine, engine_version: engine_version

gem 'rails', '~>7.0.0'

gem 'bootsnap'
gem 'bootstrap'
gem 'bootstrap_form'
gem 'jbuilder'
gem 'jquery-rails'
gem 'pg', platform: :ruby
gem 'puma'
gem 'rails-controller-testing'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'webpacker'

group :development, :test do
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end
