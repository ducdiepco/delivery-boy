module Messengers
  class MessengerFactory
    def messenger_module(message)
      "Messengers::#{message.messenger.classify}".safe_constantize
    end
  end
end
