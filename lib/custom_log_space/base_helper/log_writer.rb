# frozen_string_literal: true

module CustomLogSpace
  # The LogWriter module provides methods for writing log messages to custom log files.
  # It allows the creation of log directories, handling file errors, and appending messages to log files.
  module LogWriter
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
      return unless Dir.exist?(action_directory)

      # If there are more than 3 date-directories, remove the oldest ones
      remove_oldest_directory while all_directories.size > 2
    end

    def all_directories
      @all_directories ||= Dir.entries(action_directory).select do |entry|
        File.directory?(File.join(action_directory, entry)) && entry !~ /^\./
      end.sort
    end

    def remove_oldest_directory
      directory_to_remove = all_directories.shift
      path_to_remove = File.join(action_directory, directory_to_remove)
      FileUtils.rm_rf(path_to_remove)
    end

    def action_directory
      @action_directory ||= begin
        controller_name = Thread.current[:current_controller].underscore
        action_name = Thread.current[:current_action]
        File.join(Rails.root, "log", "custom_log_space", controller_name, action_name)
      end
    end

    def write_to_custom_log(message)
      directory_path = log_directory_based_on_format
      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)
      custom_log_path = custom_log_file_path(directory_path)

      File.open(custom_log_path, "a") do |file|
        yield(file) # Header or other info can be passed and written here
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

    def custom_log_file_path(directory_path)
      time = Time.now.strftime("%H:%M")
      "#{directory_path}/#{time}.log"
    end

    def log_directory_based_on_format
      controller_name = Thread.current[:current_controller].underscore
      action_name = Thread.current[:current_action]
      date = Time.now.strftime("%Y-%m-%d")

      File.join(Rails.root, "log", "custom_log_space", controller_name, action_name, date)
    end
  end
end
