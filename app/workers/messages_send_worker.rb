require 'sneakers'

class MessagesSendWorker
  include Sneakers::Worker
  include MessageProcessable

  EXCHANGE_PARAMS = {
    exchange_options: {
      durable: true,
      auto_delete: false
    }
  }.freeze

  from_queue('messages_for_messengers', EXCHANGE_PARAMS)

  def work(id)
    message = Message.find(id)
    process_message(message, MessagesSendWorker)
  end
end
