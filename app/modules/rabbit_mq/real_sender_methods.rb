module RabbitMq
  module RealSenderMethods
    def send_to_queue(id)
      MessagesSendWorker.enqueue(id)
    end

    def send_to_delayed_queue(id, delivery_time)
      Logger.logger.error("received: #{id} #{delivery_time}")
    end
  end
end
