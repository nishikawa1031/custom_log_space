# frozen_string_literal: true

require "custom_log_space/log_formatter"
require "custom_log_space/thread_manager"
require "custom_log_space/log_writer"

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

    private

    def log_message(message)
      current_controller = Thread.current[:current_controller]
      current_action = Thread.current[:current_action]

      return unless current_controller && current_action

      write_to_custom_log(message) do |file|
        write_header_information(file)
      end

      cleanup_old_directories
    end

    def cleanup_old_directories
      base_directory = File.join(Rails.root, "log", "custom_log_space")
      all_directories = Dir.entries(base_directory).select do |entry|
        File.directory?(File.join(base_directory, entry)) && entry !~ /^\./
      end.sort

      # If there are more than 2 date-directories, remove the oldest one
      while all_directories.size > 2
        directory_to_remove = all_directories.shift
        path_to_remove = File.join(base_directory, directory_to_remove)
        FileUtils.rm_rf(path_to_remove)
      end
    end

    def write_header_information(file)
      return if Thread.current[:header_written]

      current_controller = Thread.current[:current_controller]
      current_action = Thread.current[:current_action]

      file.puts("") # Add a blank line for better readability.
      write_request_info(file)
      write_processing_info(file, current_controller, current_action)
      write_parameters_info(file)
      Thread.current[:header_written] = true
    end

    def write_request_info(file)
      formatted_time = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      file.puts "Started GET \"#{Thread.current[:path]}\" for ::1 at #{formatted_time}"
    end

    def write_processing_info(file, current_controller, current_action)
      file.puts "Processing by #{current_controller}##{current_action} as HTML"
    end

    def write_parameters_info(file)
      params = Thread.current[:params] || {}
      file.puts "Parameters: #{params.inspect}" unless params.empty?
    end
  end
end
