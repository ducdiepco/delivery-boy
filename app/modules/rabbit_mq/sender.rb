module RabbitMq
  class Sender
    if Rails.env.test?
      include RabbitMq::StubSenderMethods
    else
      include RabbitMq::RealSenderMethods
    end
  end
end
