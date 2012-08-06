begin
  require 'rails/railtie'

  module GitHub::Deprecation
    class Railtie < Rails::Railtie
      config.to_prepare do
        # Starts reporting, warns if misconfigured.
        GitHub::Deprecation.start_reporting!
      end
    end
  end
rescue LoadError => e
  # No Rails, no-op
end