require "./spec_helper"
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

describe "My Kemal App" do
  it "renders /" do
    get "/"
    # puts response # HTTP::Client::Response  https://crystal-lang.org/api/HTTP/Client/Response.html
    response.status_code.should eq 200
    #puts response.status_message
    #puts response.headers
    response.headers["Content-Type"].should eq "text/html"
    response.body.should contain("<h1>Crystal Mine</h1>")
  end

  it "renders /github" do
    fixture(cleanup: true) do
      get "/github/szabgab/crystal-mine.cr"
      response.status_code.should eq 200
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain(%{<a href="https://github.com/szabgab/crystal-mine.cr">szabgab/crystal-mine.cr</a>})
    end
  end

  it "renders /github" do
    fixture(cleanup: true) do
      get "/github/szabgab/no-such-repo"
      response.status_code.should eq 404
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain(%{We don't know about this project})
    end
  end
  
end
