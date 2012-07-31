require "active_support"  # should be lazy anyways
require "date"
require "hashie"
require "github_deprecations/version"
require "octokit"
require "resque"

module GithubDeprecations
  def configure(options = {}, &blk)
    config = Config.new(options)
    blk.call(config) if blk
    config
  end
  module_function :configure

  class Config < Hashie::Dash  # add Dash#verify! so that it's not checked on initialization
    property :login,       :required => true
    property :oauth_token, :required => true
    property :repo,        :required => true
    property :subscribe,   :default => %r{^deprecation}
    property :labels,      :default => ['deprecations']
    property :queue,       :default => 'deprecations'

    # Register to intercept deprecation warnings.
    #
    # For each deprecation, enqueue a background job
    # to create or update an issue.
    def register!
      ActiveSupport::Deprecation.behavior = :notify
      @subscriber = ActiveSupport::Notifications.subscribe(@subscribe) do |*args|
        Resque.enqueue Worker, self, args
      end
    end

    def reset!
      ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber
    end
  end

  class Worker
    @queue = :deprecations  # too lazy to make this configurable now

    def self.perform(options, event_params)
      new(options).submit_issue!(event_params)
    end

    def initialize(options)
      @options = Hashie::Mash.new(options)  # serialization drops mash
    end

    # Create or update an issue based on deprecation warning.
    #
    # if we wanted to be fancy
    # calculating an edit-distance probably removes a lot of duplicates
    # test: when title is too long, then what? what about sha-ing the title and prefixing that to the title?
    def submit_issue!(event_params)
      # datetime objects are being serialized to string?
      event_params[1] = DateTime.parse(event_params[1])
      event_params[2] = DateTime.parse(event_params[2])

      event   = ActiveSupport::Notifications::Event.new(*event_params)
      payload = Hashie::Mash.new(event.payload)
      title   = normalize_title(payload[:message])
      body    = "```\n" + payload[:callstack].join("\n") + "\n```\n" # ghetto markdown-ify

      create_labels
      match = find_issue(title)
      res = match ?
        update_issue(match.number, title, body) :
        create_issue(title, body)
    end

    # Create any missing issue labels.
    def create_labels
      @options.labels.each do |label|
        client.add_label(@options.repo, label)
      end
    rescue Octokit::UnprocessableEntity => e
      # assume label already exists and do nothing
    end

    # Find an existing issue with the same message.
    #
    # Returns Hashie::Mash of issue if found, otherwise nil
    def find_issue(title)
      issues = client.list_issues(@options.repo, :labels => @options.labels.join(','))
      issues.detect {|i| i.title == title}
    end

    def create_issue(title, body)
      client.create_issue(@options.repo, title, body, :labels => @options.labels)
    end

    def update_issue(issue_number, title, body)
      client.update_issue(@options.repo, issue_number, title, body)
    end

    def client
      @client ||= Octokit::Client.new({
        :login       => @options.login,
        :oauth_token => @options.oauth_token
      })
    end

    # Shorten warnings and remove common stuff
    def normalize_title(warning)
      warning.
        gsub(%r{DEPRECATION WARNING: ?}, '').
        gsub(%r{ *\(called from.*}, '')
    end
  end
end