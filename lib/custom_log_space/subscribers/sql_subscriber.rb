# frozen_string_literal: true

# SQLSubscriber logs SQL related events for CustomLogSpace.
# It extends BaseSubscriber to make use of its logging capabilities.
class SQLSubscriber < CustomLogSpace::BaseSubscriber
  def sql(event)
    payload = event.payload
    name = payload[:name]
    sql = payload[:sql]
    duration = event.duration.round(1)
    message = "#{name} (#{duration}ms) #{sql}"
    log_message(message)
  end
end
