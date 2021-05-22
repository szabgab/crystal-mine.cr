require "spec-kemal"
require "../src/webapp"

require "file_utils"

def empty_fixture(cleanup = true)
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

def fixture(cleanup = true)
  empty_fixture(cleanup: cleanup) do |tempfile|
    # load data into temporary database
    # TODO eliminate the need for the sqlite3 cli
    res = system("sqlite3 #{tempfile} < spec/data.sql")
    if ! res
      raise "Could not create fixture"
    end
    yield
  end
end
