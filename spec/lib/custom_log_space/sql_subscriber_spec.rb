# frozen_string_literal: true

module Rails
  def self.root
    Pathname.new(File.expand_path("dummy", __dir__))
  end
end

require "custom_log_space/sql_subscriber"

RSpec.describe SQLSubscriber do
  let(:subscriber) { described_class.new }
  let(:expected_path) {
    Rails.root.join("log", "custom_log_space", "test_controller", "test_action", Time.now.strftime("%Y-%m-%d").to_s, Time.now.strftime("%H:%M").to_s + ".log").to_s
  }

  after do
    Thread.current.keys.each do |key|
      Thread.current[key] = nil
    end
  end

  describe "#sql" do
    let(:event) do
      double("Event", payload: {
               name: "TestSQL",
               sql: "SELECT * FROM tests"
             }, duration: 10.5)
    end

    before do
      Thread.current[:current_controller] = "TestController"
      Thread.current[:current_action] = "test_action"
      Thread.current[:params] = {}
      allow(File).to receive(:open)
    end

    it "logs the SQL event to a custom log file" do
      expect(File).to receive(:open).with(expected_path, "a")
      subscriber.sql(event)
    end

    it "logs the correct SQL message" do
      fake_file = StringIO.new
      allow(File).to receive(:open).and_yield(fake_file)

      subscriber.sql(event)
      log_output = fake_file.string

      expected_message = [
        "", # Empty line for readability
        "Started GET \"\" for ::1 at #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}",
        "Processing by TestController#test_action as HTML",
        "TestSQL (10.5ms) SELECT * FROM tests\n"
      ].join("\n")
      expect(log_output).to eq(expected_message)
    end
  end
end
