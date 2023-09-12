# frozen_string_literal: true

module CustomLogSpace
  # The LogWriter module provides methods for writing log messages to custom log files.
  # It allows the creation of log directories, handling file errors, and appending messages to log files.
  module LogWriter
    private

    def write_to_custom_log(message)
      directory_path = controller_log_directory
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

    def custom_log_file_path(directory_path)
      action_name = Thread.current[:current_action]
      log_file_name = "#{action_name}.log"
      File.join(directory_path, log_file_name)
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
  end
end
