require 'active_support/core_ext'

module MultipleMan
  class ModelPublisher

    def initialize(options = {})
      self.options = options.with_indifferent_access
      @message_publisher = Outbox::MessageAdapter.adapter
    end

    def publish(records, operation=:create)
      return unless MultipleMan.configuration.enabled

      Connection.connect do |connection|
        ActiveSupport::Notifications.instrument('multiple_man.publish_messages') do
          all_records(records) do |record|
            ActiveSupport::Notifications.instrument('multiple_man.publish_message') do
              @message_publisher.push_record(connection, record, operation, options)
            end
          end
        end
      end
    rescue Exception => ex
      err = ProducerError.new(reason: ex, payload: records.inspect)
      MultipleMan.error(err, reraise: false)
    end

    private

    attr_accessor :options

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
