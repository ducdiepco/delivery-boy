module ModelErrorMessageFormatter
  def format_error_message_for(model)
    model.errors.messages.map { |k, v| "#{k}: #{v.reduce(:+)}" }.join(', ')
  end
end
