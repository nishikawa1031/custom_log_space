# frozen_string_literal: true

module Rails
  def self.root
    Pathname.new(File.expand_path("dummy", __dir__))
  end
end

module Rack
  module Utils
    HTTP_STATUS_CODES = {
      200 => "OK"
    }.freeze
  end
end

require "custom_log_space/base_subscriber"
require "custom_log_space/log_formatter"
require "custom_log_space/thread_manager"
require "custom_log_space/log_writer"

RSpec.describe CustomLogSpace::BaseSubscriber do
  let(:subscriber) { described_class.new }
  let(:event_payload) { {} }
  let(:event) do
    double("Event", payload: event_payload, duration: 100.0, allocations: 500)
  end

  after do
    CustomLogSpace::ThreadManager.clear
  end

  before do
    allow(CustomLogSpace::ThreadManager).to receive(:setup)
    allow(CustomLogSpace::ThreadManager).to receive(:clear)
  end
  before do
    log_dir = Rails.root.join("log", "custom_log_space")
    FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)
    allow(Dir).to receive(:exist?).and_return(false)
    allow(Dir).to receive(:exist?).with(log_dir).and_return(false)
    allow(FileUtils).to receive(:mkdir_p)
  end

  describe "#start_processing" do
    let(:event_payload) do
      {
        controller: "TestController",
        action: "test_action",
        path: "/test_path",
        params: { controller: "TestController", action: "test_action", key: "value" }
      }
    end

    it "sets up the thread manager with event payload" do
      subscriber.start_processing(event)
      expect(CustomLogSpace::ThreadManager).to have_received(:setup).with(event_payload)
    end
  end

  describe "#process_action" do
    let(:event_payload) do
      {
        status: 200,
        view_runtime: 50.0,
        db_runtime: 25.0
      }
    end

    before do
      Thread.current[:current_controller] = "TestController"
      Thread.current[:current_action] = "test_action"
      Thread.current[:header_written] = false
      allow(File).to receive(:open)
    end

    it "logs the process action event to a custom log file with the correct path and filename" do
      expected_path = Rails.root.join("log", "custom_log_space", "test_controller", "test_action", Time.now.strftime("%Y-%m-%d").to_s, Time.now.strftime("%H:%M").to_s + ".log").to_s
      expect(File).to receive(:open).with(expected_path, "a").and_yield(StringIO.new)
      subscriber.process_action(event)
    end

    it "logs with the correct format including headers" do
      expected_message = [
        "", # Empty line for readability
        "Started GET \"\" for ::1 at #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}",
        "Processing by TestController#test_action as HTML",
        "Completed 200 OK in 100.0ms " \
        "(Views: 50.0ms | ActiveRecord: 25.0ms | Allocations: 500)",
        ""
      ].join("\n")

      # Use StringIO to capture file output in-memory
      fake_file = StringIO.new
      allow(File).to receive(:open).and_yield(fake_file)

      # Simulating the headers being written
      subscriber.send(:write_header_information, fake_file)

      # Logging the action processing
      subscriber.process_action(event)

      # Retrieve full log from StringIO
      log_output = fake_file.string

      expect(log_output).to eq(expected_message)
    end

    it "clears thread variables after processing" do
      subscriber.process_action(event)
      expect(CustomLogSpace::ThreadManager).to have_received(:clear)
    end
  end

  # While it's a private method, it includes error handling logic, so we should add tests for it.
  describe "#log_message" do
    let(:message) { "Test message" }
    let(:mocked_path) { "/dummy/path/to/file.log" }

    context "when file cannot be opened due to Errno::ENOENT" do
      before do
        Thread.current[:current_controller] = "TestController"
        Thread.current[:current_action] = "test_action"
        allow(CustomLogSpace::LogWriter).to receive(:custom_log_file_path).and_return(mocked_path)
        allow(File).to receive(:open).with(mocked_path, "a").and_raise(Errno::ENOENT.new("No such file or directory @ rb_sysopen - #{mocked_path}"))
      end

      it "outputs the appropriate error message" do
        expect do
          subscriber.send(:write_to_custom_log, message) do |file|
            file.puts "Header"
          end
        end.to output("Error: No such file or directory - No such file or directory @ rb_sysopen - #{mocked_path}\n").to_stdout
      end
    end

    context "when there's an IOError while writing to the file" do
      before do
        Thread.current[:current_controller] = "TestController"
        Thread.current[:current_action] = "test_action"
        fake_file = StringIO.new
        allow(fake_file).to receive(:puts).and_raise(IOError.new("dummy IOError"))
        allow(File).to receive(:open).and_yield(fake_file)
      end

      it "outputs the appropriate error message" do
        expect do
          subscriber.send(:write_to_custom_log, message) do |file|
            file.puts "Header"
          end
        end.to output("IO Error: dummy IOError\n").to_stdout
      end
    end
  end

  describe "#cleanup_old_directories" do
    let(:base_directory) { Rails.root.join("log", "custom_log_space") }

    before do
      allow(FileUtils).to receive(:rm_rf)
    end

    context "when there are more than 2 date-directories" do
      let(:directories) { %w[20230101 20230102 20230103] }

      before do
        allow(Dir).to receive(:entries).with(base_directory.to_s).and_return(directories)
        allow(File).to receive(:directory?).and_return(true)
      end

      it "removes the oldest directory to maintain only 2 date-directories" do
        expect(FileUtils).to receive(:rm_rf).with(File.join(base_directory, "20230101"))
        subscriber.send(:cleanup_old_directories)
      end
    end

    context "when there are 3 or fewer date-directories" do
      let(:directories) { %w[20230101 20230102] }

      before do
        allow(Dir).to receive(:entries).with(base_directory.to_s).and_return(directories)
        allow(File).to receive(:directory?).and_return(true)
      end

      it "does not remove any directories" do
        expect(FileUtils).not_to receive(:rm_rf)
        subscriber.send(:cleanup_old_directories)
      end
    end
  end
end
