require "spec-kemal"
require "../src/webapp"

require "file_utils"

def fixture(cleanup = true)
  tempfile = File.tempname
  #puts tempfile
  begin
    # load data into temporary database
    # TODO eliminate the need for the sqlite3 cli
    res = system("sqlite3 #{tempfile} < spec/data.sql")
    if ! res
      raise "Could not create fixture"
    end
    ENV["MINE_DB"] = tempfile
    yield
  ensure
    if cleanup
       FileUtils.rm_rf(tempfile)
    end
  end
end
