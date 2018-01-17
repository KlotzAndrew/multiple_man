module MultipleMan
  module Outbox
    module Adapter
      class MultipleManMessageRepository < Hanami::Repository
        self.relation = 'multiple_man_messages'

        def self.push_record(connection, record, operation, options)
          data = PayloadGenerator.new(record, operation, options)
          routing_key = RoutingKey.new(data.type, operation).to_s

          new.create(
            payload:     data.payload,
            routing_key: routing_key
          )
        end
      end

      class MultipleManMessage < Hanami::Entity; end
    end
  end
end
