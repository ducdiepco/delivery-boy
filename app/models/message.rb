class Message < ApplicationRecord
  enum status: %i[pending in_queue failed fax]
  enum messenger: %i[telegram whatsapp viber]

  validates :body, presence: true
  validates :messenger, presence: true
  validates :messenger_user_id, presence: true
  validates :status, presence: true
  validates :tried_to_send_times, presence: true
end
