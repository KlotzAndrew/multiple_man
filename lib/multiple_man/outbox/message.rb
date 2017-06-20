require 'sequel'

module MultipleMan
  class MultipleManMessage < MultipleMan::DB.outbox_parent #Sequel::Model(MultipleMan::DB.connection)
    BATCH_SIZE = 1000.0

    # TODO: sequel and rails queries are different
    def self.produce_all
      # order(:created_at).paged_each(&:produce)
      batches = (MultipleManMessage.count / BATCH_SIZE).ceil

      batches.times do |_|
        MultipleManMessage.order(:created_at).limit(BATCH_SIZE).each(&:produce)
      end
    end

    def produce
      MultipleMan::Connection.connect do |connection|
        connection.topic.publish(payload, routing_key: routing_key)
        clear_message(connection.channel)
      end
    end

    def clear_message(channel)
      raise ProducerError.new(reason: 'wait_for_confirms', payload: payload) unless channel.wait_for_confirms

      destroy
      MultipleMan.logger.debug("Record Data: #{payload} | Routing Key: #{routing_key}")
    end
  end
end
