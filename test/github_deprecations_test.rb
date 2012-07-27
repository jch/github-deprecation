require 'test_helper'

class GithubDeprecationsTest < Test::Unit::TestCase
  def setup
    Resque.mock!
    Mocha::Mockery.instance.stubba.unstub_all
    @app = GithubDeprecations.configure({
      :login       => 'jch',
      :oauth_token => 'oauth2token',
      :repo        => 'org/repo-name',
    })
    @app.register!
  end

  def teardown
    @app.reset!
    mocha_teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def test_create_issue
    GithubDeprecations::Worker.any_instance.stubs(:find_issue).returns(nil)
    GithubDeprecations::Worker.any_instance.expects(:create_issue)

    ActiveSupport::Deprecation.warn "Roh oh"
  end

  # how to mocha unstub all?
  def pending_test_update_existing_issue
    issue = stub(:number => '5')
    GithubDeprecations::Worker.any_instance.stubs(:find_issue).returns(issue)
    GithubDeprecations::Worker.any_instance.expects(:update_issue).with('5', any_parameters, any_parameters)

    ActiveSupport::Deprecation.warn "Roh oh"
  end
end