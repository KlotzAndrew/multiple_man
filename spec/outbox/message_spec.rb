require 'spec_helper'

describe 'MultipleMan::MultipleManMessage' do
  context '#create_message' do
    let(:payload) { 'some message' }
    let(:routing_key) { 'app.message.Create' }

    xit 'create_message creates a multiple_man_message' do
      payload     = 'some message'
      routing_key = 'app.message.Create'
      MultipleMan::Outbox.repository
      expect(MultipleMan::MultipleManMessage).to receive(
        :create_message
      ).with(payload, routing_key)

      MultipleMan::Outbox.create_message(payload, routing_key)
    end
  end
end
