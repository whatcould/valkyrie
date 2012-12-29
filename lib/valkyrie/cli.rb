require "valkyrie/database"
require "valkyrie/progress_bar"

class Valkyrie::CLI

  def self.start(*args)
    url1 = args.shift
    url2 = args.shift

    unless url1 && url2
      puts "valkyrie FROM TO [encoding]"
      exit 1
    end

    encoding_to_force = args.shift

    db1 = Valkyrie::Database.new(url1, encoding_to_force)
    db2 = Valkyrie::Database.new(url2)

    progress = nil

    db1.transfer_to(db2) do |type, data|
      case type
        when :tables then puts "Transferring #{data} tables:"
        when :table  then progress = Valkyrie::ProgressBar.new(data.first, data.last, $stdout)
        when :row    then progress.inc(data)
        when :end    then progress.finish
      end
    end
  rescue Interrupt
    puts
    puts "ERROR: Transfer aborted by user"
  end

end
