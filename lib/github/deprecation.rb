require 'active_support'
require 'active_support/core_ext/hash'

module GitHub
  module Deprecation
    extend self

    autoload :DelayedQueue,   'github/deprecation/delayed_queue'
    autoload :Reporter,       'github/deprecation/reporter'
    autoload :ResqueReporter, 'github/deprecation/resque_reporter'

    @original_behavior ||= ActiveSupport::Deprecation.behavior
    DEFAULT_CONFIG     ||= {
      :labels => ['deprecations']
    }

    def config
      @config ||= DEFAULT_CONFIG.clone
    end
    attr_writer :config

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
    # Deprecation messages are queued up until #start_reporting! is called.
    def register!
      return if @registered
      @registered = true

      self.behavior = :notify
      @subscriber = ActiveSupport::Notifications.subscribe(%r{^deprecation}) do |*args|
        queue.enqueue args
      end
    end

    # Configure credentials and behavior
    #
    # :login       - required. GitHub user login
    # :oauth_token - required. OAuth2 access token. Use `github-deprecation-auth` command to generate.
    # :repo        - required. Repository including organization or user. e.g. 'github/github-deprecation'
    # :labels      - list of label strings to apply to issues
    # :reporter    - symbol of reporter to use. `:reporter` submits in foreground, `:resque_reporter`
    #                submits in background
    def configure(options = {})
      self.config.merge!(options.symbolize_keys)

      # Default reporter based on availability of resque
      self.config[:reporter] ||= defined?(Resque) ? :resque_reporter : :reporter
      reporter_klass = self.config[:reporter].to_s.camelize
      self.config[:reporter_class] = GitHub::Deprecation.const_get(reporter_klass)

      @configured = ([:login, :oauth_token, :repo] & self.config.keys).size == 3

      self.config
    rescue NameError => e
      warn "unknown reporter #{self.config[:reporter]}"
      @configured = false
    end

    def configured?
      @configured
    end

    def registered?
      @registered
    end

    # Remove any queued deprecation messages, revert to default reporting
    # behavior.
    #
    # Passing true will also reset the configuration
    def reset!(reset_config=false)
      queue.clear
      ActiveSupport::Deprecation.behavior = @original_behavior if @original_behavior
      ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber
      @registered = false

      if reset_config
        self.config = DEFAULT_CONFIG.dup
        @configured = false
      end
    end

    def warn(message)
      $stderr.puts("WARNING: GitHub::Deprecation " + message)
    end

    # Submit any queued deprecations as issues. All future queued
    # deprecations are immediately submitted.
    def start_reporting!
      return unless registered?
      return warn("missing required config") unless configured?

      reporter_instance = self.config[:reporter_class].new(self.config)
      queue.start! do |e|
        begin
          reporter_instance.submit_issue!(e)
        rescue => e
          warn "error submitting issue: #{e.message}"
          e.backtrace.each {|line| $stderr.puts line}
          reset!
        end
      end
    end

    # Pause submitting issues.
    def pause_reporting!
      queue.pause!
    end
  end
end

require 'github/deprecation/railtie'