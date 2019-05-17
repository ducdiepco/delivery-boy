require 'rails_helper'

RSpec.describe 'Messages API', type: :request do
  describe 'POST /api/messages' do
    subject { post '/api/messages', params: params, as: :json }

    context 'when request params are valid' do
      let(:params) { { message: { body: body, consumers_info: consumers_info } } }
      let(:body) { Faker::Movies::Lebowski.quote }

      let(:consumer_hash_with_deliver_time) do
        { time_to_deliver: 1.day.after.to_i,
          messenger_user_id: Faker::Number.within(1..10),
          messenger: Message.messengers.keys.sample }
      end

      let(:consumer_hash_without_deliver_time) do
        { messenger_user_id: Faker::Number.within(1..10),
          messenger: Message.messengers.keys.sample }
      end

      let(:consumers_info) do
        [consumer_hash_with_deliver_time, consumer_hash_without_deliver_time]
      end

      it 'returns status code 201' do
        subject
        expect(response).to have_http_status(201)
      end

      it 'returns ids of created messages in response' do
        subject

        parsed_response = JSON.parse(response.body)

        expect(parsed_response['status']).to eq('accepted')

        expect(parsed_response['ids']).to be_a(Array)
        expect(parsed_response['ids'].size).to eq(2)
      end

      it 'creates messages' do
        expect { subject }.to change { Message.count }.by(2)
      end

      it 'sends messages to queue' do
        expect_any_instance_of(RabbitMq::Sender).to receive(:send_to_queue)
        expect_any_instance_of(RabbitMq::Sender).to receive(:send_to_delayed_queue)

        subject
      end
    end

    context 'when request params are invalid' do
      let(:params) { { message: { body: body, consumers_info: consumers_info } } }

      let(:valid_consumer_info) do
        { messenger_user_id: Faker::Number.within(1..10),
          messenger: Message.messengers.keys.sample }
      end

      let(:invalid_consumer_info) { { messenger: Message.messengers.keys.sample } }

      let(:consumers_info) { [valid_consumer_info, invalid_consumer_info] }

      before do
        subject
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns errors reason' do
        parsed_response = JSON.parse(response.body)

        expected_response = { 'status' => 'invalid_data',
                              'reasons' => { 'body' => ['must be filled', 'size must be within 1 - 500'],
                                             'consumers_info' => {
                                               '1' => { 'messenger_user_id' => ['is missing'] }
                                             } } }
        expect(parsed_response).to eq(expected_response)
      end

      it 'doesnt create messages' do
        expect { subject }.not_to change(Message, :count)
      end
    end
  end
end
