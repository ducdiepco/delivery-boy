module Api
  class MessagesController < ApplicationController
    # POST /api/messages
    # Создаёт сообщения для рассылки,
    # после чего кладёт их в очередь для отправки в зависимости от времени
    #
    # Данные должны быть в формате json, в хедере запроса должно быть выставлено значение:
    #   Content-Type - application/json
    #
    # Пример запроса:
    #
    # {
    #   "message": {
    #     "body":"hello my darling",
    #     "consumers_info":[
    #       {
    #         "time_to_deliver": 1558181088,
    #         "messenger_user_id": 2,
    #         "messenger": "whats_app"
    #       },
    #       {
    #         "messenger_user_id": 3,
    #         "messenger": "whats_app"
    #       }
    #     ]
    #   }
    # }
    #
    #  Описание аттрибутов:
    #    message/body - string. Обязательный параметр, текст сообщения длина может быть от 1 до 500
    #
    #    message/consumers_info - array. Обязательный параметр, массив из хешей, в котором указываются
    #                             мессенджеры, пользователи и время для отправки сообщения
    #
    #    message/consumers_info/messenger_user_id - integer. Обязательный параметр, id пользователя
    #    message/consumers_info/messenger - string. Обязательный параметр, мессенджер, куда отправляются
    #                                       сообщения. Может быть равен 'viber', 'whatsapp', 'telegram'.
    #                                       (Для примера сделал так, что все сообщения на whatsapp будут
    #                                        получать статус failed в очереди).
    #    message/consumers_info/time_to_deliver - timestamp - integer. Опциональный параметр, время, когда сообщение
    #                                             должно быть доставлено. Если время меньше текущего, то сообщение
    #                                             отправляется незамедлительно.
    #
    # Ответ
    #   В случае валидного запроса:
    #   Результат: Массив из id созданных сообщений в системе в том порядке, в котором они были указаны при запросе
    #   Пример:
    #   {
    #     "status": "accepted",
    #     "ids": [1, 2]
    #   }
    #
    #   В случае, невалидного запроса
    #   Результат: Хэш с ошибками в формате:
    #    {"reasons": {"body": [массив строк с описанием ошибок],
    #                 "consumer_info":
    #                   { Порядковый номер сообщения в запросе: {невалидное поле: [массив строк с описанием ошибок]]}}}
    #                }
    #    }
    #
    #   Пример:
    #   {
    #    "status": "invalid_data",
    #      "reasons": {
    #          "body": [
    #              "must be filled",
    #              "length must be within 1 - 500"
    #          ],
    #          "consumers_info": {
    #              "2": {
    #                  "messenger": [
    #                      "must be one of: telegram, whats_app, viber"
    #                  ]
    #              }
    #          }
    #      }
    #  }
    #
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

    # GET /api/messages/:id
    # Возращает запись Message в json-формате
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
