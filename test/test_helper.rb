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


module GitHub::Deprecation
  # Stub out access check in unit tests, unstub for integration tests
  class Reporter
    class << self
      def stub_access!
        alias_method :has_access?, :stubbed_has_access?
      end

      def unstub_access!
        alias_method :has_access?, :unstubbed_has_access?
      end
    end

    def stubbed_has_access?
      true
    end
    alias_method :unstubbed_has_access?, :has_access?

    self.stub_access!
  end

  # Raises an exception when submitting an issue
  class ErrorReporter < Reporter
    def submit_issue!(event_args)
      raise RuntimeError.new("Mock error")
    end
  end

  # Reporter that tracks what events have been submitted, but doesn't create
  # any issues. Used for testing.
  class NullReporter < Reporter
    class << self
      attr_accessor :events
    end

    def submit_issue!(event_hash)
      self.class.events ||= []
      self.class.events << event_hash
    end

    def has_access?
      true
    end
  end

  module IntegrationHelper
    extend ActiveSupport::Concern

    included do
      GitHub::Deprecation::Reporter.unstub_access!
    end
  end
end