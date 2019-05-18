module RabbitMq
  module RealSenderMethods
    def send_to_queue(id)
      MessagesSendWorker.enqueue(id.to_s)
    end

    def send_to_delayed_queue(id, delivery_time)
      delay_sec = (delivery_time - Time.zone.now).to_i * 1000

      MessagesSendDelayedWorker.enqueue(id.to_s, delay_sec)
    end
  end
end
