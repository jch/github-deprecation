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
    assert_equal output, "Missing config parameters for GithubDeprecations\n"
  end

  def test_configure_fails_noop
    # shouldn't raise no method error
    GithubDeprecations.configure.register!
  end
end