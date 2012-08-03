require 'test_helper'

class GitHub::DeprecationTest < Test::Unit::TestCase
  def subject
    GitHub::Deprecation
  end

  def setup
    subject.reset!
  end

  def test_behavior_default
    assert_equal ActiveSupport::Deprecation.behavior, subject.behavior
  end

  def test_behavior_reset
    original_behavior = ActiveSupport::Deprecation.behavior
    subject.behavior = [:notify, :log]
    assert_equal ActiveSupport::Deprecation.behavior, subject.behavior

    subject.reset!
    assert_equal original_behavior, ActiveSupport::Deprecation.behavior
  end

  def test_register_queues_deprecations
    subject.register!
    ActiveSupport::Deprecation.warn "Keep on dancing"

    assert_equal 1, subject.queue.size
  end

  def test_defaults
    assert_equal ['deprecations'], subject.config[:labels]
  end

  def test_configure_override
    subject.configure({:foo => 'bar'})
    subject.configure({:foo => 'baz'})
    assert_equal 'baz', subject.config[:foo]
  end

  def test_configured
    assert !subject.configured?, "missing config params"
    subject.configure(valid_config)
    assert subject.configured?, "valid config"
  end
end