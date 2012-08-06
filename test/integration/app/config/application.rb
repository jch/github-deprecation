require 'github/deprecation'

ActiveSupport::Deprecation.warn "STRANGER DANGER"

require "action_controller/railtie"

module App
  class Application < Rails::Application
    # Print deprecation notices to the Rails logger
    # This should be overridden by github-deprecation
    config.active_support.deprecation = :log
  end
end

ActiveSupport::Deprecation.warn "Post Application load warning"

# Initialize the rails application
App::Application.initialize!

ActiveSupport::Deprecation.warn "Post Application initialize warning"