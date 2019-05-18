module Messages
  class CreatingBatch
    include Dry::Transaction
    include SchemaValidated
    include ModelErrorMessageFormatter

    @validation_schema = Dry::Validation.Schema do
      configure { config.input_processor = :sanitizer }

      required(:body).filled(:str?, size?: 1..500)

      required(:consumers_info).value(:array?, :filled?) do
        each do
          schema do
            optional(:time_to_deliver).maybe(:int?)
            required(:messenger_user_id).filled(:int?)
            required(:messenger).filled(included_in?: Message.messengers.keys)
          end
        end
      end
    end

    step :validate_input
    map  :build_models_hash
    step :validate_models
    step :save_models

    private

    def build_models_hash(body:, consumers_info:)
      indexed_models = consumers_info.each_with_object(index: 0, res_hash: {}) do |el, res_hash|
        time_to_deliver = el[:time_to_deliver] && Time.zone.at(el[:time_to_deliver])

        model = Message.new(el.merge(body: body, time_to_deliver: time_to_deliver))

        res_hash[:res_hash][res_hash[:index]] = model
        res_hash[:index] += 1
        res_hash
      end

      { indexed_models_arr: indexed_models[:res_hash] }
    end

    def validate_models(indexed_models_arr:)
      invalid_indexed_models = indexed_models_arr.reject { |_index, model| model.valid? }

      if invalid_indexed_models.empty?
        valid_models = indexed_models_arr.map(&:second)
        return Success(valid_models: valid_models)
      end

      error_hash = invalid_indexed_models.map do |index, model|
        { index => format_error_message_for(model) }
      end

      Failure(error_hash)
    end

    def save_models(valid_models:)
      valid_models.each(&:save)
      Success(valid_models)
    end
  end
end
