require 'sneakers'

Sneakers.configure(Rails.application.config.x.rabbitmq_settings)
Sneakers.logger = Logger.new(Rails.root.join('log', 'sneakers_events.log'))
