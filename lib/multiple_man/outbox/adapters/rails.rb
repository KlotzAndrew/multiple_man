module MultipleMan
  module Outbox
    module Adapter
      class Rails < ::ActiveRecord::Base
        self.table_name = 'multiple_man_messages'

        def self.push_record(connection, record, operation, options)
          data        = PayloadGenerator.new(record, operation, options)
          routing_key = RoutingKey.new(data.type, operation).to_s

          new(
            payload:     data.payload,
            routing_key: routing_key
          ).save!
        end
      end
    end
  end
end
