require 'test_helper'

class GitHub::Deprecation::RailsTest < Test::Unit::TestCase
  def test_railtie
    # Load rails, fixture throws deprecations before loading rails, and after
    # rails is loaded.
    GitHub::Deprecation.configure(:reporter => :null_reporter)

    output = capture_stderr do
      require File.expand_path('../app/config/environment', __FILE__)
    end

    assert_equal "", output
    assert_equal 2, GitHub::Deprecation::NullReporter.events.size
  end
end