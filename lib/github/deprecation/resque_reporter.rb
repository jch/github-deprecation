require 'date'

module GitHub::Deprecation
  class ResqueReporter < Reporter
    @queue = :deprecations

    def submit_issue!(event_params)
      Resque.enqueue self.class, @options, event_params
    end

    def self.perform(options, event_params)
      options.symbolize_keys!

      # fix values flattened by serialization
      event_params[1] = DateTime.parse(event_params[1])
      event_params[2] = DateTime.parse(event_params[2])
      event_params.last.symbolize_keys!

      Reporter.new(options).submit(event_params)
    end
  end
end