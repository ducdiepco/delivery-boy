require 'rails_helper'

RSpec.describe Message, type: :model do
  # validations
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:messenger) }
  it { is_expected.to validate_presence_of(:messenger_user_id) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:tried_to_send_times) }
end
