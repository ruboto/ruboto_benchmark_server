# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

Rails.application.load_tasks

task test: 'db:reset'

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  namespace :test do
    desc 'Run Rubocop and all tests'
    task full: %i[rubocop:auto_correct log:clear test]
  end
end
