# frozen_string_literal: true

require "custom_log_space/base_helper/log_formatter"
require "custom_log_space/base_helper/thread_manager"
require "custom_log_space/base_helper/log_writer"

module CustomLogSpace
  # CustomLogSpace::Subscriber is a class for handling custom logging in Rails applications.
  # It provides methods for processing different types of log events and organizing log messages.
  # https://github.com/rails/rails/blob/7-0-stable/activesupport/lib/active_support/log_subscriber.rb
  class BaseSubscriber < ActiveSupport::LogSubscriber
    include CustomLogSpace::LogWriter
    include CustomLogSpace::LogFormatter

    def start_processing(event)
      ThreadManager.setup(event.payload)
    end

    def process_action(event)
      message = format_message(event)
      log_message(message)
      ThreadManager.clear
    end
  end
end
