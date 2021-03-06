require 'forwardable'

module MultipleMan
  class Runner
    extend Forwardable

    MODES = [:general, :seed].freeze

    def initialize(options = {})
      @mode = options.fetch(:mode, :general)

      raise ArgumentError, "undefined mode: #{mode}" unless MODES.include?(mode)
    end

    def run
      trap_signals!
      preload_framework!
      channel.prefetch(prefetch_size)
      build_listener.listen
    end

    private

    attr_reader :mode

    def_delegators :config, :prefetch_size, :queue_name, :listeners, :topic_name

    def trap_signals!
      handler = proc do |signal|
        puts "received #{Signal.signame(signal)}"
        channel.close
        connection.close

        exit
      end

      %w(INT QUIT TERM).each { |signal| Signal.trap(signal, handler) }
    end

    def preload_framework!
      Rails.application.eager_load! if defined?(Rails)
      if defined?(Hanami)
        if Hanami::Application.respond_to?(:preload_applications!)
          Hanami::Application.preload_applications!
        end
        if Hanami.respond_to?(:boot)
          Hanami.boot
        end
      end
    end

    def build_listener
      listener_class.new(
        queue: channel.queue(*queue_params),
        subscribers: listeners,
        topic: topic_name
      )
    end

    def listener_class
      if seeding?
        Consumers::Seed
      else
        Consumers::General
      end
    end

    def queue_params
      if seeding?
        ["#{queue_name}.seed", durable: false, auto_delete: true]
      else
        [queue_name, durable: true, auto_delete: false]
      end
    end

    def channel
      @channel ||= connection.create_channel
    end

    def connection
      Connection.connection
    end

    def config
      MultipleMan.configuration
    end

    def seeding?
      mode == :seed
    end
  end
end
