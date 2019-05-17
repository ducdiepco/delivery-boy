class Message < ApplicationRecord
  LENGTH_LIMITS = {
    min: 1,
    max: 500
  }.freeze

  enum status: %i[pending in_queue failed fax]
  enum messenger: %i[telegram whatsapp viber]

  validates :body, presence: true, length: { minimum: LENGTH_LIMITS[:min], maximum: LENGTH_LIMITS[:max] }
  validates :messenger, presence: true
  validates :messenger_user_id, presence: true
  validates :status, presence: true
  validates :tried_to_send_times, presence: true
end
