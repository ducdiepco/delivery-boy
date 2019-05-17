require 'sneakers'

Sneakers.configure(Rails.application.config.x.rabbitmq_settings)
Sneakers.logger.level = Logger::INFO
