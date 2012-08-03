require 'active_support'
require 'active_support/core_ext/hash'

module GitHub
  module Deprecation
    extend self

    autoload :DelayedQueue,   'github/deprecation/delayed_queue'
    autoload :Reporter,       'github/deprecation/reporter'
    autoload :ResqueReporter, 'github/deprecation/resque_reporter'

    attr_accessor :config
    attr_accessor :reporter  # Class to use for submitting issues. Defaults to `Reporter`

    self.config        ||= {
      :labels   => ['deprecations'],
      :reporter => :reporter
    }
    @original_behavior ||= ActiveSupport::Deprecation.behavior

    def behavior
      ActiveSupport::Deprecation.behavior
    end

    def behavior=(list)
      ActiveSupport::Deprecation.behavior = list
    end

    def queue
      @queue ||= DelayedQueue.new
    end

    # Register to intercept deprecation warnings.
    #
    # Deprecation messages are queued up until #start! is called.
    def register!
      return if @registered
      @registered = true

      self.behavior = :notify
      @subscriber = ActiveSupport::Notifications.subscribe(%r{^deprecation}) do |*args|
        queue.enqueue args
      end
    end

    # Configure GitHub credentials and optional issue labels
    #
    #
    def configure(options = {})
      self.config = options.symbolize_keys.merge(self.config)
      self.config[:reporter_class] = GitHub::Deprecation.const_get(self.config[:reporter].to_s.camelize)

      @configured = ([:login, :oauth_token, :repo] & self.config.keys).size == 3
    rescue LoadError => e
      warn "unknown reporter #{self.config[:reporter]}"
      @configured = false
    end

    # Verify configuration is valid
    def configured?
      @configured
    end

    # Remove any queued deprecation messages, revert to default reporting
    # behavior.
    def reset!
      queue.clear
      ActiveSupport::Deprecation.behavior = @original_behavior if @original_behavior
      ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber
      @registered = false
    end

    def warn(message)
      $stderr.puts("WARNING: GitHub::Deprecation " + message)
    end

    def start_reporting!
      return warn("missing required config") unless configured?

      reporter_instance = self.config[:reporter_class].new(self.config)
      @queue.start! do |e|
        reporter_instance.submit_issue!(e)
      end
    end

    def pause_reporting!
      @queue.pause!
    end
  end
end

require 'github/deprecation/railtie' if defined?(Rails)