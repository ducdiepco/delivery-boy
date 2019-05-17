module RabbitMq
  module StubSenderMethods
    def send_to_queue(id)
      Rails.logger.info("StubSender: put the message: #{id}")
    end

    def send_to_delayed_queue(id, delivery_time)
      Rails.logger.info("StubSender: put the message: #{id} to the delayed queue #{delivery_time}")
    end
  end
end
