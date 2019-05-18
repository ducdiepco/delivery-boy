class Message < ApplicationRecord
  LENGTH_LIMITS = {
    min: 1,
    max: 500
  }.freeze

  MAX_NUMBER_OF_RETRIES = 3

  enum status: %i[pending in_queue failed success]
  enum messenger: %i[telegram whats_app viber]

  validates :body, presence: true, length: { minimum: LENGTH_LIMITS[:min], maximum: LENGTH_LIMITS[:max] }
  validates :messenger, presence: true
  validates :messenger_user_id, presence: true
  validates :status, presence: true
  validates :tried_to_send_times, presence: true, numericality: { less_than_or_equal_to: MAX_NUMBER_OF_RETRIES }

  def acceptable_for_retry?
    tried_to_send_times < MAX_NUMBER_OF_RETRIES
  end
end
