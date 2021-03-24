# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    fixtures :all
    parallelize

    def assert_no_errors(symbol)
      v = assigns(symbol)
      assert v
      assert_equal [], v.errors.full_messages
    end
  end
end
