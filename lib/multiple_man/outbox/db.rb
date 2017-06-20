require 'sequel'

module MultipleMan
  module DB
    module_function

    TABLE_NAME = :multiple_man_messages

    def connection
      @connection ||= begin
        url = ENV['DATABASE_URL']
        Sequel.connect(url)
      end
    end

    def setup!
      connection.create_table?(TABLE_NAME) do
        primary_key :id
        String :routing_key
        String :payload
        DateTime :created_at, null: false, default: "NOW()"
        DateTime :updated_at, null: false, default: "NOW()"
      end

      # requiring this at runtime allows listeners to skip creating a table
      require 'multiple_man/outbox/message' unless defined?(MultipleManMessage)
    end

    def outbox_parent
      return ActiveRecord::Base if defined?(ActiveRecord)

      Sequel::Model(MultipleMan::DB.connection)
    end
  end
end
