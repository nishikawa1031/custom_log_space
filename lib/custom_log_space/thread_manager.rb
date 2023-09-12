# frozen_string_literal: true

module CustomLogSpace
  # The ThreadManager class provides methods for managing thread-local variables related to logging in a Rails application.
  # It is responsible for setting up and clearing thread-local variables such as controller, action, path, params, and header_written.
  class ThreadManager
    # https://railsguides.jp/v6.1/active_support_instrumentation.html#start-processing-action-controller
    # Sets up thread-local variables based on the provided payload.
    #
    # @param payload [Hash] The payload containing information about the current request.
    #
    # Example:
    #
    #   payload = {
    #     controller: 'HomeController',
    #     action: 'index',
    #     path: '/home',
    #     params: { id: 1, page: 2 }
    #   }
    #
    #   CustomLogSpace::ThreadManager.setup(payload)
    #
    def self.setup(payload)
      Thread.current[:current_controller] = payload[:controller]
      Thread.current[:current_action] = payload[:action]
      Thread.current[:path] = payload[:path]
      Thread.current[:params] = payload[:params].except(:controller, :action)
      Thread.current[:header_written] = false
    end

    def self.clear
      Thread.current[:current_controller] = nil
      Thread.current[:current_action] = nil
      Thread.current[:path] = nil
      Thread.current[:params] = nil
      Thread.current[:header_written] = nil
    end
  end
end
