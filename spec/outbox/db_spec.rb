require 'spec_helper'
require 'tempfile'

describe MultipleMan::DB do
  before do
    tmpfile = Tempfile.new(['sqlite3', '.db'])
    ENV['DATABASE_URL'] = "sqlite:#{tmpfile.path}"
  end
  after { ENV.delete('DATABASE_URL') }

  let(:conn) { MultipleMan::DB.connection }

  it 'returns a db connection' do
    test_adapter_class = 'Sequel::SQLite::Database'

    expect(conn.class.to_s).to eq(test_adapter_class)
  end

  it 'calls create table if not exists' do
    expect(conn.table_exists?(MultipleMan::DB::TABLE_NAME)).to eq(false)

    MultipleMan::DB.setup!

    expect(conn.table_exists?(MultipleMan::DB::TABLE_NAME)).to eq(true)
  end
end
