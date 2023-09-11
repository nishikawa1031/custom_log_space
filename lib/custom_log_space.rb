# frozen_string_literal: true

require "custom_log_space/base_subscriber"
require "custom_log_space/sql_subscriber"
require "custom_log_space/view_subscriber"

CustomLogSpace::BaseSubscriber.attach_to :action_controller
SQLSubscriber.attach_to :active_record
ViewSubscriber.attach_to :action_view
