
module MultipleMan
  module Producers
    class General
      SLEEP_TIMEOUT = 2
      BATCH_SIZE    = 1000.0

      def run_producer
        MultipleMan.logger.info "Starting producer"

        require_relative '../outbox/adapters/general'

        last_run = Time.now
        loop do
          timeout(last_run)
          produce_all
          last_run = Time.now
        end
      end

      private

      def produce_all
        count = MultipleMan::Outbox::Adapters::General.count
        batches  = (count / BATCH_SIZE).ceil

        batches.times do |_i|
          messages = MultipleMan::Outbox::Adapters::General.order(:created_at).limit(BATCH_SIZE)
          messages.each { |message| publish(message) }
        end
      end

      def publish(message)
        MultipleMan::Connection.connect do |connection|
          connection.topic.publish(
            message.values[:payload],
            routing_key: message.values[:routing_key]
          )
          clear_message(message, connection.channel)
        end
      end

      def clear_message(message, channel)
        raise ProducerError.new(channel.nacked_set.to_a) unless channel.wait_for_confirms

        message.destroy
        MultipleMan.logger.debug(
          "Record Data: #{message.values[:payload]} | Routing Key: #{message.values[:routing_key]}"
        )
      end

      def timeout(last_run)
        time_since_last = Time.now - last_run
        sleep_time      = SLEEP_TIMEOUT - time_since_last

        sleep sleep_time if time_since_last < SLEEP_TIMEOUT
      end
    end
  end
end
