require "spec-kemal"
require "../src/webapp"

require "file_utils"

def full_database()
  return [{"id" => 1, "host" => "github.com", "user_name" => "szabgab", "repo_name" => "crystal-mine.cr", "name" => "Crystal Mine"}, {"id" => 2, "host" => "github.com", "user_name" => "watzon", "repo_name" => "octokit.cr", "name" => "octokit"}, {"id" => 3, "host" => "github.com", "user_name" => "luckyframework", "repo_name" => "lucky", "name" => "lucky"}, {"id" => 4, "host" => "github.com", "user_name" => "soveran", "repo_name" => "toro", "name" => "toro"}]
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
