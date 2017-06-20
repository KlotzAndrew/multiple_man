require 'spec_helper'

describe "Publishing of ephermal models" do
  before do
    expect(MultipleMan::DB).to receive(
      :setup!
    ).and_return(true)
    # expect(MultipleMan::DB).to receive(:connection).and_return(:mock_conn)
    # require 'multiple_man/outbox/message'
  end

  let(:ephermal_class) do
    Class.new do
      def self.name
        'Ephermal'
      end

      attr_accessor :foo, :bar, :baz, :id
      def initialize(params)
        self.id = params[:id]
        self.foo = params[:foo]
        self.bar = params[:bar]
        self.baz = params[:baz]
      end

      include MultipleMan::Publisher
      publish fields: [:foo, :bar, :baz]
    end
  end

  it "should publish properly" do
    obj = ephermal_class.new(id: 5, foo: 'foo', bar: 'bar', baz: 'baz')

    payload = {
      type: 'Ephermal',
      operation: 'create',
      id: { id: 5 },
      data: { foo: 'foo', bar: 'bar', baz: 'baz'}
    }.to_json

    expect(MultipleMan::MultipleManMessage).to receive(
      :create
    ).with(payload, 'multiple_man.Ephermal.create')

    obj.multiple_man_publish(:create)
  end

end
