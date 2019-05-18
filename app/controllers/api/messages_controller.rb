module Api
  class MessagesController < ApplicationController
    def create
      Messages::CreatingBatch.new.call(create_params) do |res|
        res.success do |messages|
          messages.each { |m| Messages::SendToQueue.new.call(message: m, sender: RabbitMq::Sender.new) }

          render json: { status: :accepted, ids: messages.pluck(:id) }, status: :created
        end

        res.failure do |failed_messages_info|
          render json: { status: :invalid_data, reasons: failed_messages_info }, status: :ok
        end
      end
    end

    def show
      render json: Message.find(params[:id]), status: :ok
    end

    private

    def create_params
      params.require(:message)
            .permit(:body, consumers_info: %i[time_to_deliver messenger_user_id messenger])
            .to_h
            .deep_symbolize_keys
    end
  end
end
