# frozen_string_literal: true

module CustomLogSpace
  # CustomLogSpace::Subscriber is a class for handling custom logging in Rails applications.
  # It provides methods for processing different types of log events and organizing log messages.
  class BaseSubscriber < ActiveSupport::LogSubscriber
    def start_processing(event)
      setup_thread_variables(event.payload)
    end

    def process_action(event)
      payload = event.payload
      status = payload[:status]
      duration = event.duration.round(2)
      view_runtime = payload[:view_runtime]&.round(2)
      db_runtime = payload[:db_runtime]&.round(2)
      allocations = event.allocations

      message = "Completed #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} in #{duration}ms " \
          "(Views: #{view_runtime}ms | ActiveRecord: #{db_runtime}ms | Allocations: #{allocations})"

      log_message(message)
      clear_thread_variables
    end

    private

    def setup_thread_variables(payload)
      Thread.current[:current_controller] = payload[:controller]
      Thread.current[:current_action] = payload[:action]
      Thread.current[:path] = payload[:path]
      Thread.current[:params] = payload[:params].except(:controller, :action)
      Thread.current[:header_written] = false
    end

    def clear_thread_variables
      Thread.current[:current_controller] = nil
      Thread.current[:current_action] = nil
      Thread.current[:path] = nil
      Thread.current[:params] = nil
      Thread.current[:header_written] = nil
    end

    def log_message(message)
      current_controller = Thread.current[:current_controller]
      current_action = Thread.current[:current_action]

      return unless current_controller && current_action

      FileUtils.mkdir_p(controller_log_directory) unless Dir.exist?(controller_log_directory)
      write_to_custom_log(message)
    end

    def custom_log_directory
      today = Time.now.strftime("%Y%m%d")
      time = Time.now.strftime("%H%M")
      File.join(Rails.root, "log", "custom_log_space", today, time)
    end

    def controller_log_directory
      controller_name = Thread.current[:current_controller].underscore
      File.join(custom_log_directory, controller_name)
    end

    def custom_log_file_path
      action_name = Thread.current[:current_action]
      log_file_name = "#{action_name}.log"
      File.join(controller_log_directory, log_file_name)
    end

    def write_to_custom_log(message)
      custom_log_path = custom_log_file_path

      File.open(custom_log_path, "a") do |file|
        write_header_information(file)
        file.puts(message)
      end
    rescue SystemCallError, IOError => e
      handle_file_error(e)
    end

    def handle_file_error(error)
      error_prefix = error.is_a?(SystemCallError) ? "Error" : "IO Error"
      puts "#{error_prefix}: #{error.message}"
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
