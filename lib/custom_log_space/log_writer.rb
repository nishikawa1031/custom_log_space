# frozen_string_literal: true

module CustomLogSpace
  # The LogWriter class provides methods for writing log messages to custom log files.
  # It allows the creation of log directories, handling file errors, and appending messages to log files.
  class LogWriter
    def self.write_to_custom_log(directory_path, message)
      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)
      custom_log_path = custom_log_file_path(directory_path)

      File.open(custom_log_path, "a") do |file|
        yield(file) # Header or other info can be passed and written here
        file.puts(message)
      end
    rescue SystemCallError, IOError => e
      handle_file_error(e)
    end

    def self.custom_log_file_path(directory_path)
      action_name = Thread.current[:current_action]
      log_file_name = "#{action_name}.log"
      File.join(directory_path, log_file_name)
    end

    def self.handle_file_error(error)
      error_prefix = error.is_a?(SystemCallError) ? "Error" : "IO Error"
      puts "#{error_prefix}: #{error.message}"
    end
  end
end
