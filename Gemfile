source 'https://rubygems.org'

/(?<ruby_engine>.*)-(?<engine_version>.*)/ =~ File.read('.ruby-version').strip

ruby ruby_engine == 'ruby' ? engine_version : '~>2.3', engine: ruby_engine, engine_version: engine_version

gem 'rails', '~>4.2.5'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'therubyrhino'
end

platform :ruby do
  gem 'pg'
  gem 'mini_racer'
end

gem 'bootstrap', '~> 4.0.0.alpha3'
gem 'bootstrap_form'
gem 'coffee-rails', '~> 4.0.0'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'puma'
gem 'rails-assets-tether' # Needed for bootstrap 4 tooltips and popovers
gem 'sass-rails'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :test do
  gem 'minitest-reporters'
end

group :production do
  gem 'rails_12factor'
end
