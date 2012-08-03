require 'test_helper'
require 'stringio'

class GithubDeprecationsTest < Test::Unit::TestCase
  def capture_stderr(&blk)
    io = StringIO.new
    old_io, $stderr = $stderr, io
    blk.call
    $stderr.string
  ensure
    $stderr = old_io
  end

  def test_configure_fails_silently
    output = capture_stderr do
      GithubDeprecations.configure
    end
    assert_equal output, "WARNING: Missing config parameters for GithubDeprecations\n"
  end

  def test_configure_fails_noop
    # shouldn't raise no method error
    capture_stderr do
      GithubDeprecations.configure.register!
    end
  end

  def test_redis_unavailable_resets
    Resque.expects(:enqueue).raises(Errno::ECONNREFUSED)
    output = capture_stderr do
      GithubDeprecations.configure({
        :login       => 'some_login',
        :oauth_token => 'some_token',
        :repo        => 'some/repo'
      }).register!
      ActiveSupport::Deprecation.warn "Roh oh"
    end
    assert_equal output, "WARNING: Unable to connect to redis for GithubDeprecations\n"
  end
end