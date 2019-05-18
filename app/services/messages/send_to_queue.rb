module Messages
  class SendToQueue
    include Dry::Transaction
    include SchemaValidated
    include ModelErrorMessageFormatter

    @validation_schema = Dry::Validation.Schema do
      required(:message).filled(type?: Message)
      required(:sender).filled
    end

    step :validate_input
    step :check_message_status
    step :change_message_status
    map  :send_to_right_queue

    private

    def check_message_status(input)
      return Success(input) if input[:message].pending?

      Failure('wrong status of the message')
    end

    def change_message_status(input)
      message = input[:message]
      return Success(input) if message.update(status: :in_queue)

      Failure(format_error_message_for(message))
    end

    def send_to_right_queue(message:, sender:)
      if message.time_to_deliver && Time.zone.now < message.time_to_deliver
        sender.send_to_delayed_queue(message.id, message.time_to_deliver)
      else
        sender.send_to_queue(message.id.to_s)
      end
    end
  end
end
