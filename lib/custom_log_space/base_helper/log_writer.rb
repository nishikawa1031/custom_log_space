# frozen_string_literal: true

module CustomLogSpace
  # The LogWriter module provides methods for writing log messages to custom log files.
  # It allows the creation of log directories, handling file errors, and appending messages to log files.
  module LogWriter
    private

    def current_controller
      Thread.current[:current_controller]
    end

    def current_action
      Thread.current[:current_action]
    end

    def log_message(message)
      return unless current_controller && current_action

      write_to_custom_log(message) do |file|
        write_header_information(file)
      end

      cleanup_old_directories
    end

    def cleanup_old_directories
      return unless Dir.exist?(base_directory_path)

      # If there are more than 2 date-directories, remove the oldest ones
      remove_oldest_directory while all_directories.size > 2
    end

    def all_directories
      @all_directories ||= Dir.entries(base_directory_path).select do |entry|
        File.directory?(File.join(base_directory_path, entry)) && entry !~ /^\./
      end.sort
    end

    def remove_oldest_directory
      directory_to_remove = all_directories.shift
      path_to_remove = File.join(base_directory_path, directory_to_remove)
      FileUtils.rm_rf(path_to_remove)
    end

    def base_directory_path
      File.join(Rails.root, "log", "custom_log_space", current_controller.underscore, current_action)
    end

    def write_to_custom_log(message)
      directory_path = File.join(base_directory_path, Time.now.strftime("%Y-%m-%d"))
      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)
      custom_log_path = "#{directory_path}/#{Time.now.strftime("%H:%M")}.log"

      File.open(custom_log_path, "a") do |file|
        yield(file) # Header or other info can be passed and written here
        file.puts(message)
      end

      cleanup_old_log_files(directory_path)
    rescue SystemCallError, IOError => e
      error_prefix = e.is_a?(SystemCallError) ? "Error" : "IO Error"
      puts "#{error_prefix}: #{e.message}"
    end

    def cleanup_old_log_files(directory_path)
      log_files = Dir.entries(directory_path).select { |entry| entry =~ /\.log$/ }.sort
      while log_files.size > 10
        oldest_log_file = log_files.shift
        path_to_remove = File.join(directory_path, oldest_log_file)
        File.delete(path_to_remove)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def write_header_information(file)
      return if Thread.current[:header_written]

      file.puts("") # Add a blank line for better readability.
      file.puts "Started GET \"#{Thread.current[:path]}\" for ::1 at #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}"
      file.puts "Processing by #{current_controller}##{current_action} as HTML"

      params = Thread.current[:params] || {}
      file.puts "Parameters: #{params.inspect}" unless params.empty?

      Thread.current[:header_written] = true
    end
    # rubocop:enable Metrics/AbcSize
  end
end
