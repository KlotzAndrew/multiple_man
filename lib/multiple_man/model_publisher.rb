require 'active_support/core_ext'

module MultipleMan
  class ModelPublisher
    def initialize(options = {})
      DB.setup!

      self.options = options.with_indifferent_access
    end

    def publish(records, operation = :create)
      return unless MultipleMan.configuration.enabled

      ActiveSupport::Notifications.instrument('multiple_man.publish_messages') do
        all_records(records) do |record|
          ActiveSupport::Notifications.instrument('multiple_man.publish_message') do
            create_message(record, operation)
          end
        end
      end
    rescue Exception => ex
      MultipleMan.error(ex)
    end

    private

    attr_accessor :options

    def create_message(record, operation)
      data        = PayloadGenerator.new(record, operation, options)
      routing_key = RoutingKey.new(data.type, operation).to_s

      MultipleManMessage.create(payload: data.payload, routing_key: routing_key)
    end

    def all_records(records, &block)
      if records.respond_to?(:find_each)
        records.find_each(batch_size: 100, &block)
      elsif records.respond_to?(:each)
        records.each(&block)
      else
        yield records
      end
    end
  end
end
