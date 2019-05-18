module MessageProcessable
  include ModelErrorMessageFormatter

  def process_message(message, resend_worker_class)
    Workers::Logger.info("#{self.class} received #{message.id}. Retries: #{message.tried_to_send_times}")

    Messages::SendToMessenger.new.call(message: message) do |res|
      res.success { success_case(message) }

      res.failure { |reason| failure_case(message, resend_worker_class, reason) }
    end
  end

  def success_case(message)
    Workers::Logger.info("Processing #{message.id} is successfully completed")

    message.update(status: :success)
    ack!
  end

  def failure_case(message, resend_worker_class, fail_reason)
    Workers::Logger.error("Processing #{message.id} is failed. Reason: #{fail_reason}")

    update_message(message)

    return reject! unless message.acceptable_for_retry?

    requeue_to(resend_worker_class, message.id)
    ack!
  end

  def update_message(message)
    message.tried_to_send_times += 1

    message.status = :failed unless message.acceptable_for_retry?

    return if message.save

    Workers::Logger.error("Saving #{message.id} is failed. Reason: #{format_error_message_for(message)}")
  end

  def requeue_to(resend_worker_class, id)
    Workers::Logger.error("Requeue #{id} to: #{resend_worker_class}")
    resend_worker_class.enqueue(id.to_s)
  end
end
