ENV["KEMAL_ENV"] = "test"
require "spec-kemal"
require "../src/webapp"

require "file_utils"

def full_database()
  return [{"id" => 1, "host" => "github.com", "user_name" => "szabgab", "repo_name" => "crystal-mine.cr", "name" => "Crystal Mine", "record_last_updated" => "2021-05-25 14:59:16.972", "description" => "Experimenting with Crystal\n", "version" => "0.0.1", "shard_yml" => true, "travis_ci" => false, "github_actions" => true, "crystal" => "", "license" => "MIT"}, {"id" => 2, "host" => "github.com", "user_name" => "luckyframework", "repo_name" => "lucky", "name" => "lucky", "record_last_updated" => "2021-05-25 14:59:18.172", "description" => "", "version" => "0.27.2", "shard_yml" => true, "travis_ci" => false, "github_actions" => true, "crystal" => ">=0.36.1, < 2.0.0", "license" => "MIT"}, {"id" => 3, "host" => "github.com", "user_name" => "soveran", "repo_name" => "toro", "name" => "toro", "record_last_updated" => "2021-05-25 14:59:19.160", "description" => "", "version" => "0.4.2", "shard_yml" => true, "travis_ci" => false, "github_actions" => true, "crystal" => ">= 0.36.0 - 1.0", "license" => "MIT"}, {"id" => 4, "host" => "github.com", "user_name" => "watzon", "repo_name" => "octokit.cr", "name" => "octokit", "record_last_updated" => "2021-05-25 14:59:21.176", "description" => "", "version" => "0.1.0", "shard_yml" => true, "travis_ci" => true, "github_actions" => false, "crystal" => ">= 1.0.0", "license" => "MIT"}]
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
