# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  config.action_controller.perform_caching = true
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
  config.action_mailer.perform_caching = false
  # config.action_mailer.raise_delivery_errors = false
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "ruboto_benchmarks_server_production"
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
  # config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :local
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  # config.asset_host = 'http://assets.example.com'
  config.assets.compile = false
  # config.assets.css_compressor = :sass
  config.assets.js_compressor = Uglifier.new(harmony: true)
  config.cache_classes = true
  # config.cache_store = :mem_cache_store
  config.consider_all_requests_local = false
  config.eager_load = true
  # config.force_ssl = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  config.log_tags = [:request_id]
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  # config.require_master_key = true

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end
