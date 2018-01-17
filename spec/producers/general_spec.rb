require 'spec_helper'

describe MultipleMan::Producers::General do
  context '#produce' do
    let(:subject) { described_class.new }

    before(:each) do
      setup_db
    end

    after(:each) do
      clear_db
    end

    it '#run_producer runs producer' do
      MultipleMan.configuration.messaging_mode = :at_least_once

      MultipleMan::Connection.connect do |connection|
        expect(connection.topic).to receive(:publish).with("payload", {:routing_key=>"rk"})
      end

      expect(subject).to receive(:loop).and_yield

      create_messages(1)

      subject.run_producer

      expect(MultipleMan::Outbox::Adapters::General.count).to eq(0)
    end

    it '#run_producer raises when wait_for_confirms fails' do
      MultipleMan.configuration.messaging_mode = :at_least_once

      expect(subject).to receive(:loop).and_yield

      MultipleMan::Connection.connect do |connection|
        expect(connection.channel).to receive(:wait_for_confirms).and_return(false)
      end

      create_messages(1)

      expect {
        subject.run_producer
      }.to raise_error(MultipleMan::ProducerError)
    end

    it '#run_producer does not hammer db' do
      MultipleMan.configuration.messaging_mode = :at_least_once

      expect(subject).to receive(:loop).and_yield

      st = Time.now

      create_messages(1)

      subject.run_producer

      et = Time.now

      (et - st).should be >= MultipleMan::Producers::General::SLEEP_TIMEOUT
    end
  end
end
