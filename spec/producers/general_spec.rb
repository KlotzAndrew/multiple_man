require 'spec_helper'

describe MultipleMan::Producers::General do
  context '#produce' do
    let(:subject) { described_class.new }

    before { expect(MultipleMan::Outbox).to receive(:connection).and_return('mock_conn') }

    it '#run_producer runs producer' do
      expect(subject).to receive(:produce).and_return(true)

      subject.run_producer
    end

    it '#producer produces all messages' do
      expect_any_instance_of(MultipleMan::Producers::General).to receive(:loop).and_yield
      expect(subject).to receive(:timeout).and_return(true)
      expect(MultipleMan::Outbox).to receive(:produce_all_messages).and_return(true)

      subject.produce
    end
  end
end
