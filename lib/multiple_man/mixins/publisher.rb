require 'active_support/core_ext'

module MultipleMan
  module Publisher
    def self.included(base)
      base.extend(ClassMethods)

      base.class_attribute :multiple_man_publisher

      add_hook_create(base) if base.respond_to?(:after_create)
      add_hook_update(base) if base.respond_to?(:after_update)
      add_hook_destroy(base) if base.respond_to?(:after_destroy)
    end

    def self.add_hook_create(base)
      base.after_create { |r| r.multiple_man_publish(:create) }
    end

    def self.add_hook_update(base)
      base.after_update do |r|
        if !r.respond_to?(:saved_changes) || r.saved_changes.any?
          r.multiple_man_publish(:update)
        end
      end
    end

    def self.add_hook_destroy(base)
      base.after_destroy { |r| r.multiple_man_publish(:destroy) }
    end

    def multiple_man_publish(operation = :create)
      self.class.multiple_man_publisher.publish(self, operation)
    end

    module ClassMethods
      def multiple_man_publish(operation = :create)
        multiple_man_publisher.publish(self, operation)
      end

      def publish(options = {})
        self.multiple_man_publisher = ModelPublisher.new(options)
      end
    end
  end
end
