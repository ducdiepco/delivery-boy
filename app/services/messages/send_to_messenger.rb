module Messages
  class SendToMessenger
    include Dry::Transaction
    include SchemaValidated

    @validation_schema = Dry::Validation.Schema do
      required(:message).filled(type?: Message)
    end

    step :validate_input
    step :choose_messenger
    step :make_request

    private

    def choose_messenger(message:)
      messenger_class = Messengers::MessengerFactory.new.messenger_module(message)

      return Failure("messenger module not found for #{message.id}") if messenger_class.nil?

      Success(message: message, messenger: messenger_class.new)
    end

    def make_request(input)
      Messengers::StubRequesting.new.call(input)
    end
  end
end
