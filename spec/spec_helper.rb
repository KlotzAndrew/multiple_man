require 'bundler/setup'
require 'bunny'
require 'ostruct'
require 'pry'

require_relative '../lib/multiple_man.rb'

MultipleMan.configure do |config|
  config.exchange_opts             = { durable: true }
  config.logger.level              = 'FATAL'
  MultipleMan.configuration.db_url = 'postgresql://0.0.0.0:5432/postgres'
end

def setup_db
  MultipleMan::Outbox::DB.run_migrations
  db_conn.execute <<~SQL
    CREATE TABLE mm_test_users (
      id         BIGSERIAL PRIMARY KEY,
      name       varchar(255),
      created_at TIMESTAMP default NOW(),
      updated_at TIMESTAMP default NOW()
    )
  SQL
end

def create_messages(num)
  message = {
    routing_key: 'rk',
    payload:     'payload',
    created_at:  Time.now,
    updated_at:  Time.now
  }
  num.times { MultipleMan::Outbox::Adapters::General.insert(message) }
end

def db_conn
  MultipleMan::Outbox::DB.connection
end

def clear_db
  db_conn.drop_table :multiple_man_schema_info
  db_conn.drop_table :multiple_man_messages
  db_conn.drop_table :mm_test_users
end
