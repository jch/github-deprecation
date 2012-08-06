require 'test_helper'

class GitHub::Deprecation::ReporterTest < Test::Unit::TestCase
  # See ActiveSupport::Notification::Event
  def event_args
    @event_args ||= [
      "deprecation.rails",  # label
      Time.now - 100,       # time started
      Time.now,             # time ended
      "db26e5c0ab87",       # message id
      {
        :message   => "DEPRECATION WARNING: Keep on dancing. (called from test_register_queues_deprecations at /Users/jch/github-deprecations/test/deprecations_test.rb:27)",
        :callstack => [
          "/Users/jch/github/github-deprecation/test/deprecations_test.rb:27:in ...",
          "/Users/jch/github/github-deprecation/test/deprecations_test.rb:20:in ..."
        ]
      }
    ]
  end

  def subject(options = {})
    @subject ||= GitHub::Deprecation::Reporter.new(options.merge(valid_config(:labels => [])))
  end

  def test_create_issue
    subject.stubs(:find_issue).returns(nil)
    subject.expects(:create_issue)
    subject.submit_issue!(event_args)
  end

  def test_update_existing_issue
    issue = stub(:number => '5')
    subject.stubs(:find_issue).returns(issue)
    subject.expects(:update_issue).with('5', any_parameters, any_parameters)
    subject.submit_issue!(event_args)
  end

  def test_title_normalization
    normalized = subject.normalize_title("DEPRECATION WARNING: Ooga Booga. (called from irb_binding at (irb):1)")
    assert_equal "Ooga Booga.", normalized
  end
end