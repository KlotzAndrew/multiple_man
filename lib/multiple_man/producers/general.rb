module MultipleMan
  module Producers
    class General
      DEFAULT_REQUEST_TIMEOUT = 5

      def run_producer
        MultipleMan.logger.debug "Starting producer"
        produce
      rescue ConnectionError, ProducerError => err
        MultipleMan.error(err, reraise: false)
        run_producer
      end

      def produce
        last_run = Time.now
        loop do
          timeout(last_run)
          MultipleManMessage.produce_all
          last_run = Time.now
        end
      end

      private

      def timeout(last_run)
        current           = Time.now
        time_since        = current - last_run
        min_sleep_time    = DEFAULT_REQUEST_TIMEOUT - time_since
        less_than_timeout = time_since < DEFAULT_REQUEST_TIMEOUT

        sleep min_sleep_time if less_than_timeout
      end
    end
  end
end
