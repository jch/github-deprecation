require 'test_helper'

class GitHub::DeprecationTest < Test::Unit::TestCase
  def subject
    GitHub::Deprecation
  end

  def setup
    subject.reset!(true)
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

  def test_configure_reporter
    subject.configure({:reporter => :resque_reporter})
    assert_equal GitHub::Deprecation::ResqueReporter, subject.config[:reporter_class]
  end

  def test_configure_invalid_reporter
    capture_stderr {
      subject.configure({:reporter => :foo})
    }
    assert !subject.configured?
  end

  def test_configured
    assert !subject.configured?, "missing config params"
    subject.configure(valid_config)
    assert subject.configured?, "valid config"
  end

  def test_start_reporting_error
    subject.queue.enqueue 'unicorns'
    subject.configure(valid_config.merge(:reporter => :error_reporter))
    output = capture_stderr do
      subject.start_reporting!
    end
    assert_match /Mock error/, output
    assert !subject.registered?
  end
end