# frozen_string_literal: true

module CustomLogSpace
  # The LogFormatter module is responsible for formatting log messages.
  module LogFormatter
    private

    def format_message(event)
      payload = event.payload
      status = payload[:status]
      duration = event.duration.round(2)
      view_runtime = payload[:view_runtime]&.round(2)
      db_runtime = payload[:db_runtime]&.round(2)
      allocations = event.allocations

      "Completed #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]} in #{duration}ms " \
          "(Views: #{view_runtime}ms | ActiveRecord: #{db_runtime}ms | Allocations: #{allocations})"
    end
  end
end
