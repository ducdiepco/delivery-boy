module Messengers
  class WhatsApp
    def url(user_id, message_body)
      "whatsapp.api/send_message=#{message_body}_to_user#{user_id}"
    end
  end
end
