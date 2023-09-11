# frozen_string_literal: true

# ViewSubscriber logs view rendering events for CustomLogSpace.
# It tracks events like template rendering, partial rendering, and collection rendering.
class ViewSubscriber < CustomLogSpace::BaseSubscriber
  def render_template(event)
    identifier = event.payload[:identifier]
    duration = event.duration.round(2)
    allocations = event.allocations
    message = "Rendered #{identifier} (Duration: #{duration}ms | Allocations: #{allocations})"

    log_message(message)
  end

  def render_partial(event)
    identifier = event.payload[:identifier]
    duration = event.duration.round(2)
    allocations = event.allocations
    message = "Rendered partial #{identifier} (Duration: #{duration}ms | Allocations: #{allocations})"

    log_message(message)
  end

  def render_collection(event)
    identifier = event.payload[:identifier]
    count = event.payload[:count]
    duration = event.duration.round(2)
    allocations = event.allocations
    message = "Rendered collection #{identifier} (#{count} items) (Duration: #{duration}ms | Allocations: #{allocations})"

    log_message(message)
  end
end
