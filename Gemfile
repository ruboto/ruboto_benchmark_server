source 'https://rubygems.org'

# FIXME(uwe): Ruby version is also set in .ruby-version file.  NOT DRY!
ruby '2.2.3', engine: 'jruby', engine_version: '9.0.5.0'

gem 'rails', '~>4.2.5'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'therubyrhino'
end

platform :ruby do
  gem 'sqlite3'
  gem 'therubyracer'
end

gem 'bootstrap', '~> 4.0.0.alpha3'
gem 'bootstrap_form'
gem 'coffee-rails', '~> 4.0.0'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'puma'
# Needed for bootstrap 4 tooltips and popovers
source 'http://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end
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
