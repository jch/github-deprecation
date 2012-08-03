require 'octokit'

module GitHub::Deprecation
  class Reporter
    def initialize(options)
      @options = options
    end

    # Override this method in subclasses to configure custom issue submission
    def submit_issue!(event_params)
      submit(event_params)
    end

    # Create or update an issue based on deprecation warning.
    def submit(event_params)
      event   = ActiveSupport::Notifications::Event.new(*event_params)
      title   = normalize_title(event.payload[:message])
      body    = "```\n" + event.payload[:callstack].join("\n") + "\n```\n" # ghetto markdown-ify

      create_labels
      match = find_issue(title)
      res = match ?
        update_issue(match.number, title, body) :
        create_issue(title, body)
    end

    # Create any missing issue labels.
    def create_labels
      @options[:labels].each do |label|
        client.add_label(@options[:repo], label)
      end
    rescue Octokit::UnprocessableEntity => e
      # assume label already exists and do nothing
    end

    # Find an existing issue with the same message.
    #
    # Returns Hashie::Mash of issue if found, otherwise nil
    def find_issue(title)
      issues = client.list_issues(@options[:repo], :labels => @options[:labels].join(','))
      issues.detect {|i| i.title == title}
    end

    def create_issue(title, body)
      client.create_issue(@options[:repo], title, body, :labels => @options[:labels])
    end

    def update_issue(issue_number, title, body)
      client.update_issue(@options[:repo], issue_number, title, body)
    end

    def client
      @client ||= Octokit::Client.new({
        :login       => @options[:login],
        :oauth_token => @options[:oauth_token]
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