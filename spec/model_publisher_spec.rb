require 'spec_helper'

describe MultipleMan::ModelPublisher do
  before do
    expect(MultipleMan::Outbox).to receive(:setup_table!).and_return(true)
    MultipleMan.configure do |config|
      config.topic_name = "app"
    end
  end

  class MockObject
    def foo
      "bar"
    end

    def id
      10
    end

    def model_name
      OpenStruct.new(singular: "mock_object")
    end
  end

  subject { described_class.new(fields: [:foo]) }

  describe "publish" do
    it "should send the jsonified version of the model to the correct routing key" do
      MultipleMan::AttributeExtractor.any_instance.should_receive(:as_json).and_return({foo: "bar"})
      MultipleMan::Outbox.should_receive(:create_message).with('{"type":"MockObject","operation":"create","id":{"id":10},"data":{"foo":"bar"}}', "app.MockObject.create")
      described_class.new(fields: [:foo]).publish(MockObject.new)
    end

    it "should call the error handler on error" do
      ex = Exception.new("Bad stuff happened")
      MultipleMan::Outbox.stub(:create_message) { raise ex }
      MultipleMan.should_receive(:error).with(ex)
      described_class.new(fields: [:foo]).publish(MockObject.new)
    end
  end

  describe "with a serializer" do
    class MySerializer
      def initialize(record)
      end

      def as_json
        { a: "yes" }
      end
    end

    subject { described_class.new(with: MySerializer) }

    it "should get its data from the serializer" do
      obj = MockObject.new
      MultipleMan::Outbox.should_receive(:create_message).with('{"type":"MockObject","operation":"create","id":{"id":10},"data":{"a":"yes"}}', "app.MockObject.create")
      subject.publish(obj)
    end
  end
end
