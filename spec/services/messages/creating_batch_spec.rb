require 'rails_helper'

RSpec.describe Messages::CreatingBatch do
  describe '#call' do
    subject { described_class.new.call(body: body, consumers_info: consumers_info) }

    let(:body) { Faker::Movies::Lebowski.quote }

    let(:consumer_hash) do
      { time_to_deliver: 300,
        messenger_user_id: Faker::Number.within(1..10),
        messenger: Message.messengers.keys.sample }
    end

    let(:consumers_info) do
      [consumer_hash, consumer_hash]
    end

    context 'with invalid input params' do
      context 'body of a message is empty' do
        let(:body) { nil }

        it { is_expected.to eq(Dry::Monads::Failure(body: ['must be filled', 'size must be within 1 - 500'])) }
      end

      context 'consume_info is empty' do
        let(:consumers_info) { [] }

        it { is_expected.to eq(Dry::Monads::Failure(consumers_info: ['must be filled'])) }
      end

      context 'consume_info is invalid' do
        let(:consumers_info) { [{ messenger_user_id: nil, messenger: 'undefined' }] }

        it 'returns failure' do
          err_hash = { consumers_info: {
            0 => { messenger_user_id: ['must be filled'],
                   messenger: ["must be one of: #{Message.messengers.keys.join(', ')}"] }
          } }

          expect(subject).to eq(Dry::Monads::Failure(err_hash))
        end
      end
    end

    context 'with valid input params' do
      it { is_expected.to be_a(Dry::Monads::Success) }

      it 'creates messages' do
        expect { subject }.to change { Message.count }.by(2)
      end

      it 'created messages are in pending status' do
        status = subject.success.map(&:status).uniq

        expect(status).to eq(%w[pending])
      end
    end
  end
end
