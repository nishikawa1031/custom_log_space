# frozen_string_literal: true

require "custom_log_space/base_helper/log_writer"

module Rails
  def self.root
    Pathname.new(File.expand_path("dummy", __dir__))
  end
end

RSpec.describe CustomLogSpace::LogWriter do
  let(:dummy_class) { Class.new { include CustomLogSpace::LogWriter } }
  let(:dummy_instance) { dummy_class.new }

  let(:controller_name) { "sample_controller" }
  let(:action_name) { "sample_action" }
  let(:base_directory) { File.join(Rails.root, "log", "custom_log_space", controller_name, action_name) }
  before do
    # This allows us to call private methods for testing purposes.
    dummy_class.class_eval do
      public :cleanup_old_directories
    end
  end

  before do
    original_thread = Thread.current

    allow(Thread).to receive(:current) { original_thread }
    allow(Thread.current).to receive(:[]).with(:current_controller).and_return(controller_name)
    allow(Thread.current).to receive(:[]).with(:current_action).and_return(action_name)
  end

  describe "#cleanup_old_directories" do
    before do
      FileUtils.mkdir_p(base_directory)
    end

    after do
      FileUtils.rm_rf(base_directory)
    end

    context "with more than three date directories" do
      let(:dates) { %w[2023-09-01 2023-09-02 2023-09-03 2023-09-04] }

      before do
        dates.each do |date|
          FileUtils.mkdir_p(File.join(base_directory, date))
        end

        dummy_instance.cleanup_old_directories
      end

      it "removes the oldest directory" do
        expect(Dir.exist?(File.join(base_directory, dates.first))).to be(false)
      end

      it "keeps the three newest directories" do
        expect(Dir.exist?(File.join(base_directory, dates[1]))).to be(true)
        expect(Dir.exist?(File.join(base_directory, dates[2]))).to be(true)
        expect(Dir.exist?(File.join(base_directory, dates[3]))).to be(true)
      end
    end

    context "with three or fewer date directories" do
      let(:dates) { %w[2023-09-01 2023-09-02 2023-09-03] }

      before do
        dates.each do |date|
          FileUtils.mkdir_p(File.join(base_directory, date))
        end

        dummy_instance.cleanup_old_directories
      end

      it "does not remove any directories" do
        dates.each do |date|
          expect(Dir.exist?(File.join(base_directory, date))).to be(true)
        end
      end
    end
  end
end
