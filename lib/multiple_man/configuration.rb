module MultipleMan
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  class Configuration
    attr_reader :subscriber_registry
    attr_accessor :topic_name, :app_name, :connection, :enabled, :error_handler,
                  :worker_concurrency, :reraise_errors, :connection_recovery,
                  :queue_name

    attr_writer :logger

    def initialize
      self.topic_name = "multiple_man"
      self.app_name = Rails.application.class.parent.to_s if defined?(Rails)
      self.enabled = true
      self.worker_concurrency = 1
      self.reraise_errors = true
      self.connection_recovery = {
        time_before_reconnect: 0.2,
        time_between_retries: 0.8,
        max_retries: 5
      }

      @subscriber_registry = Subscribers::Registry.new
      self.queue_name = "#{topic_name}.#{app_name}"
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    def on_error(&block)
      @error_handler = block
    end

    def listeners
      subscriber_registry.subscriptions
    end

    def register_listener(listener)
      subscriber_registry.register(listener)
    end
  end
end
