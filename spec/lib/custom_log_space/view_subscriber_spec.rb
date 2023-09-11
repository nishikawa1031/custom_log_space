# frozen_string_literal: true

module Rails
  def self.root
    Pathname.new(File.expand_path("dummy", __dir__))
  end
end

require "custom_log_space/view_subscriber"

RSpec.describe ViewSubscriber do
  let(:subscriber) { described_class.new }

  after do
    Thread.current.keys.each do |key|
      Thread.current[key] = nil
    end
  end

  describe "#render_template" do
    let(:event) do
      double("Event", payload: {
               identifier: "test_template.html.erb"
             }, duration: 30.0, allocations: 300)
    end

    before do
      Thread.current[:current_controller] = "TestController"
      Thread.current[:current_action] = "test_action"
      allow(File).to receive(:open)
    end

    it "logs the render template event to a custom log file" do
      expected_path = Rails.root.join("log", "custom_log_space", Time.now.strftime("%Y%m%d").to_s, Time.now.strftime("%H%M").to_s,
                                      "test_controller", "test_action.log").to_s
      expect(File).to receive(:open).with(expected_path, "a")
      subscriber.render_template(event)
    end

    it "logs the correct render template message" do
      fake_file = StringIO.new
      allow(File).to receive(:open).and_yield(fake_file)

      subscriber.render_template(event)
      log_output = fake_file.string
      expected_message = [
        "", # Empty line for readability
        "Started GET \"\" for ::1 at #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}",
        "Processing by TestController#test_action as HTML",
        "Rendered test_template.html.erb (Duration: 30.0ms | Allocations: 300)\n"
      ].join("\n")
      expect(log_output).to eq(expected_message)
    end
  end

  describe "#render_partial" do
    let(:event) do
      double("Event", payload: {
               identifier: "test_partial.html.erb"
             }, duration: 20.0, allocations: 200)
    end

    before do
      Thread.current[:current_controller] = "TestController"
      Thread.current[:current_action] = "test_action"
      allow(File).to receive(:open)
    end

    it "logs the render partial event to a custom log file" do
      expected_path = Rails.root.join("log", "custom_log_space", Time.now.strftime("%Y%m%d").to_s, Time.now.strftime("%H%M").to_s,
                                      "test_controller", "test_action.log").to_s
      expect(File).to receive(:open).with(expected_path, "a")
      subscriber.render_partial(event)
    end

    it "logs the correct render partial message" do
      fake_file = StringIO.new
      allow(File).to receive(:open).and_yield(fake_file)

      subscriber.render_partial(event)
      log_output = fake_file.string
      expected_message = [
        "", # Empty line for readability
        "Started GET \"\" for ::1 at #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}",
        "Processing by TestController#test_action as HTML",
        "Rendered partial test_partial.html.erb (Duration: 20.0ms | Allocations: 200)\n"
      ].join("\n")
      expect(log_output).to eq(expected_message)
    end
  end

  describe "#render_collection" do
    let(:event) do
      double("Event", payload: {
               identifier: "test_collection.html.erb",
               count: 5
             }, duration: 40.0, allocations: 400)
    end

    before do
      Thread.current[:current_controller] = "TestController"
      Thread.current[:current_action] = "test_action"
      allow(File).to receive(:open)
    end

    it "logs the render collection event to a custom log file" do
      expected_path = Rails.root.join("log", "custom_log_space", Time.now.strftime("%Y%m%d").to_s, Time.now.strftime("%H%M").to_s,
                                      "test_controller", "test_action.log").to_s
      expect(File).to receive(:open).with(expected_path, "a")
      subscriber.render_collection(event)
    end

    it "logs the correct render collection message" do
      fake_file = StringIO.new
      allow(File).to receive(:open).and_yield(fake_file)

      subscriber.render_collection(event)
      log_output = fake_file.string
      expected_message = [
        "", # Empty line for readability
        "Started GET \"\" for ::1 at #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}",
        "Processing by TestController#test_action as HTML",
        "Rendered collection test_collection.html.erb (5 items) (Duration: 40.0ms | Allocations: 400)\n"
      ].join("\n")
      expect(log_output).to eq(expected_message)
    end
  end
end
