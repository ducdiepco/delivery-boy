require 'rails_helper'

RSpec.describe Messages::SendToQueue do
  describe '#call' do
    subject { described_class.new.call(message: message, sender: sender) }

    let(:message) { create(:message, :pending) }
    let(:sender) { RabbitMq::Sender.new }

    context 'with invalid params' do
      context 'when the message is empty' do
        let(:message) { nil }

        it { is_expected.to eq(Dry::Monads::Failure(message: ['must be filled', 'must be Message'])) }
      end

      context 'when the sender is empty' do
        let(:sender) { nil }

        it { is_expected.to eq(Dry::Monads::Failure(sender: ['must be filled'])) }
      end
    end

    context 'with valid params' do
      context 'when the message is not in the pending status' do
        let(:message) { create(:message, :in_queue) }

        it { is_expected.to eq(Dry::Monads::Failure('wrong status of the message')) }
      end

      context 'when the message is in the pending status' do
        it { is_expected.to be_a(Dry::Monads::Success) }

        it 'changes the status of the message to in_queue' do
          expect { subject }.to change(message.reload, :status).from('pending').to('in_queue')
        end

        context 'when the message has delivery time' do
          let(:message) { create(:message, :pending, time_to_deliver: 1.day.after) }

          it 'sends message to delayed queue' do
            expect(sender).to receive(:send_to_delayed_queue)
            subject
          end
        end

        context 'when the message doesnt have delivery time' do
          let(:message) { create(:message, :pending, time_to_deliver: nil) }

          it 'sends message to ordinary queue' do
            expect(sender).to receive(:send_to_queue)
            subject
          end
        end

        context 'when delivery time run out' do
          let(:message) { create(:message, :pending, time_to_deliver: 1.day.before) }

          it 'sends message to ordinary queue' do
            expect(sender).to receive(:send_to_queue)
            subject
          end
        end
      end
    end
  end
end
