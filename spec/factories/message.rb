FactoryBot.define do
  factory :message, class: Message do
    body { Faker::Lorem.sentence }
    messenger { Message.messengers.keys.sample }
    messenger_user_id { Faker::Number.digit }
    tried_to_send_times { 0 }

    trait :pending do
      status { Message.statuses[:pending] }
    end

    trait :in_queue do
      status { Message.statuses[:in_queue] }
    end
  end
end
