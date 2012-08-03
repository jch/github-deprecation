module GitHub::Deprecation
  class Railtie < Rails::Railtie
    config.before_configuration do
      # Register as early as possible to catch more warnings.
      # Warnings are enqueued and sent after gem is configured.
      GitHub::Deprecation.register!
    end

    config.to_prepare do
      # Starts reporting, warns if misconfigured.
      GitHub::Deprecation.start_reporting!
    end
  end
end