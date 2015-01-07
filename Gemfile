source 'http://rubygems.org'

ruby '1.9.3', engine: 'jruby', engine_version: '1.7.18'

gem 'rails', '4.1.8'

platform :jruby do
# gem 'activerecord-jdbcpostgresql-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
end

platform :ruby do
  # gem 'pg'
  gem 'sqlite3'
end

gem 'puma'
# gem 'calendar_date_select', git: 'http://github.com/paneq/calendar_date_select.git', branch: 'rails3test'

group :test do
  gem 'minitest-reporters'
end
