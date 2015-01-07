ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v
    assert_equal [], v.errors.full_messages
  end

end
