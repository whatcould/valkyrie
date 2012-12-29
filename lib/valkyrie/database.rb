require "sequel"
require "valkyrie"

class Valkyrie::Database

  Sequel.extension :schema_to_hash
  Sequel.extension :pagination

  attr_reader :connection

  def initialize(uri, encoding_to_force = nil)
    @connection = Sequel.connect(uri)
    @encoding_to_force = encoding_to_force
    Sequel::MySQL.convert_invalid_date_time = nil if @connection.adapter_scheme == :mysql
  end

  def transfer_to(db, &cb)
    cb.call(:tables, tables.length)
    tables.each do |name|
      cb.call(:table, [name, connection[name].count])
      transfer_table(name, db, &cb)
    end
  end

  def transfer_table(name, db, &cb)
    db.connection.drop_table(name) if db.connection.table_exists?(name)
    db.connection.hash_to_schema(name, connection.schema_to_hash(name), &cb)

    columns = connection.schema(name).map(&:first)
    dataset = connection[name.to_sym]

    cb.call(:rows)
    buffer = []
    count = 0

    dataset.each do |row|
      buffer << row
      count  += 1

      if buffer.length > 500
        cb.call(:row, count)
        send_rows(db, name, columns, buffer)
        buffer.clear
        count=0
      end
    end

    cb.call(:row, count)
    send_rows(db, name, columns, buffer) if buffer.length > 0
    cb.call(:end)

    columns
  end

  def send_rows(db, name, columns, rows)
    data = rows.map { |row| columns.map { |c| cleanup_strings(row[c]) } }
    db.connection[name].insert_multiple data
  end

  def cleanup_strings(column_data)
    if @encoding_to_force && column_data.is_a?(String)
      column_data.encode(@encoding_to_force, {:invalid => :replace, :undef => :replace})
    else
      column_data
    end
  end

  def tables
    @tables ||= connection.tables
  end

end

