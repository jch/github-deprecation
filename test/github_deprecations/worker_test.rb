require 'test_helper'

class GithubDeprecations::WorkerTest < Test::Unit::TestCase
  def setup
    @worker = GithubDeprecations::Worker.new({
      :login       => 'jch',
      :oauth_token => 'oauth2token',
      :repo        => 'org/repo-name',
      :labels      => []
    })
    # name, start, ending, transaction_id, payload. see ActiveSupport::Notifications::Event
    @event = [
      'deprecation.rails',
      '2012-07-27 20:33:56 -0700',
      '2012-07-27 20:34:03 -0700',
      '13',
      {
        :message   => "DEPRECATION WARNING: Ooga Booga. (called from irb_binding at (irb):1)",
        :callstack => ['stack1', 'stack2']
      }
    ]
  end

  def test_create_issue
    # name, start, ending, transaction_id, payload
    @worker.stubs(:find_issue).returns(nil)
    @worker.expects(:create_issue)
    @worker.submit_issue!(@event)
  end

  def test_update_existing_issue
    issue = stub(:number => '5')
    @worker.stubs(:find_issue).returns(issue)
    @worker.expects(:update_issue).with('5', any_parameters, any_parameters)
    @worker.submit_issue!(@event)
  end

  def test_title_normalization
    normalized = @worker.normalize_title("DEPRECATION WARNING: Ooga Booga. (called from irb_binding at (irb):1)")
    assert_equal "Ooga Booga.", normalized
  end
end