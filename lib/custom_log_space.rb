# frozen_string_literal: true

require "custom_log_space/subscribers/base_subscriber"
require "custom_log_space/subscribers/sql_subscriber"
require "custom_log_space/subscribers/view_subscriber"

CustomLogSpace::BaseSubscriber.attach_to :action_controller
SQLSubscriber.attach_to :active_record
ViewSubscriber.attach_to :action_view
