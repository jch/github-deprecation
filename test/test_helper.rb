require 'bundler/setup'

require 'github/deprecation'
require 'test/unit'
require 'mocha'
require 'resque/mock'
require 'debugger'

Resque.mock!

def capture_stderr(&blk)
  io = StringIO.new
  old_io, $stderr = $stderr, io
  blk.call
  $stderr.string
ensure
  $stderr = old_io
end

def valid_config(options = {})
  {
    :login       => 'jch',
    :oauth_token => 'oauth2token',
    :repo        => 'org/repo-name',
    :labels      => ['deprecations']
  }.merge(options)
end

# Raises an exception when submitting an issue
module GitHub::Deprecation
  class ErrorReporter < Reporter
    def submit_issue!(event_args)
      raise RuntimeError.new("Mock error")
    end
  end
end