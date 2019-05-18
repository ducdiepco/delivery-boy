module SchemaValidated
  extend ActiveSupport::Concern

  included do
    def validate_input(input)
      self.class.validation_schema.call(input).to_monad
    end
  end

  class_methods do
    attr_reader :validation_schema
  end
end
