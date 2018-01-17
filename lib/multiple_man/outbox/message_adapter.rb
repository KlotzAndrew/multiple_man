module MultipleMan
  module Outbox
    module MessageAdapter
      module_function

      def adapter
        return DirectToRmq unless MultipleMan.configuration.at_least_once?

        if defined?(Rails)
          require_relative 'adapters/rails'
          return Outbox::Adapter::Rails
        elsif defined?(Hanami)
          require_relative 'adapters/hanami'
          return Outbox::Adapter::MultipleManMessageRepository
        else
          raise 'NoOutboxAdapter'
        end
      end

      def count
        adapter.count
      end

      class DirectToRmq
        def self.push_record(connection, record, operation, options)
          data = PayloadGenerator.new(record, operation, options)
          routing_key = RoutingKey.new(data.type, operation).to_s

          MultipleMan.logger.debug("Record Data: #{data} | Routing Key: #{routing_key}")

          connection.topic.publish(data.payload, routing_key: routing_key)
        end
      end
    end
  end
end
