require 'sneakers'

class MessagesSendDelayedWorker
  include Sneakers::Worker
  include MessageProcessable

  EXCHANGE_PARAMS = {
    exchange: 'delayed.exchange',
    exchange_options: {
      type: 'x-delayed-message',
      arguments: { 'x-delayed-type' => 'direct' },
      durable: true,
      auto_delete: false
    }
  }.freeze

  QUEUE_NAME = 'delayed_messages'.freeze

  from_queue(QUEUE_NAME, EXCHANGE_PARAMS)

  def self.enqueue(msg, delay, opts = {})
    super(msg, opts.merge(headers: { 'x-delay' => delay.to_i },
                          routing_key: QUEUE_NAME))
  end

  def work(id)
    message = Message.find(id)
    process_message(message, MessagesSendWorker)
  end
end
