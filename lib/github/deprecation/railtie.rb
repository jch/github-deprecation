begin
  require 'rails/railtie'

  # Register as early as possible to catch more warnings.
  # Warnings are enqueued and sent after gem is configured.
  GitHub::Deprecation.register!

  module GitHub::Deprecation
    class Railtie < Rails::Railtie
      config.to_prepare do
        GitHub::Deprecation.behavior = :notify

        # Starts reporting, warns if misconfigured.
        GitHub::Deprecation.start_reporting!
      end
    end
  end
rescue LoadError => e
  # No Rails, no-op
end