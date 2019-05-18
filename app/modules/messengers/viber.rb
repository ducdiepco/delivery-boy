module Messengers
  class Telegram
    def url(user_id, message_body)
      "viber.api/send/#{message_body}&to_user#{user_id}"
    end
  end
end
