module Messengers
  class StubRequesting
    include Dry::Transaction
    include SchemaValidated

    @validation_schema = Dry::Validation.Schema do
      required(:message).filled(type?: Message)
      required(:messenger).filled
    end

    step :validate_input
    step :send_message_to_messenger

    private

    # Логика реализована для примера
    # Все сообщения для вайбера и телеграма будут посылаться
    # Все сообщения для whatsapp будут отклоняться
    def send_message_to_messenger(message:, messenger:)
      return Failure('problem with connection') if messenger.is_a?(Messengers::WhatsApp)

      messenger.url(message.body, message.messenger_user_id)

      Success('success')
    end
  end
end
