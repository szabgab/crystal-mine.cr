ENV["KEMAL_ENV"] = "test"
require "spec-kemal"
require "../src/webapp"

require "file_utils"

# TODO is there some way to get to the current crystal executable?
CRYSTAL = "crystal"

def clean(items)
  items.each {|item|
      if ! item.nil?
        item.record_last_updated = ""
      end
  }
end

def full_database()
  return Array(Shard).from_json(File.read("spec/data.json"))
end


def no_db_fixture(cleanup = true)
    tempfile = File.tempname
    #puts tempfile
    begin

      ENV["MINE_DB"] = tempfile
      yield tempfile
    ensure
      if cleanup
         FileUtils.rm_rf(tempfile)
      end
    end
end

def empty_db_fixture(cleanup = true)
  no_db_fixture(cleanup: cleanup) do
    create_db
    yield
  end
end

def db_fixture(cleanup = true)
  no_db_fixture(cleanup: cleanup) do |tempfile|
    # load data into temporary database
    # TODO eliminate the need for the sqlite3 cli
    res = system("sqlite3 #{tempfile} < spec/data.sql")
    if ! res
      raise "Could not create fixture"
    end
    yield
  end
end

def capture(cmd, params)
  process = Process.new(cmd, params,
      output: Process::Redirect::Pipe,
      error: Process::Redirect::Pipe,
      )

  output = process.output.gets_to_end
  error  = process.error.gets_to_end

  res = process.wait

  return output, error, res.exit_status
end
