require 'active_support/core_ext'

module MultipleMan
  module Publisher
    def Publisher.included(base)
      base.extend(ClassMethods)
      if base.respond_to?(:after_save)
        base.after_save do |r|
          if !r.respond_to?(:previous_changes) || r.previous_changes.any?
            r.multiple_man_publish(:update)
          end
        end
      end

      if base.respond_to?(:before_destroy)
        base.before_destroy { |r| r.multiple_man_publish(:destroy) }
      end

      if base.respond_to?(:after_create)
        base.after_create { |r| r.multiple_man_publish(:create) }
      end

      base.class_attribute :multiple_man_publisher
    end

    def multiple_man_publish(operation=:create)
      self.class.multiple_man_publisher.publish(self, operation)
    end

    module ClassMethods

      def multiple_man_publish(operation=:create)
        multiple_man_publisher.publish(self, operation)
      end

      def publish(options = {})
        self.multiple_man_publisher = ModelPublisher.new(options)
      end
    end
  end
end
