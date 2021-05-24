require "./spec_helper"

describe "Web Application with empty database" do
  it "renders /" do
    empty_db_fixture(cleanup: true) do
      get "/"
      response.status_code.should eq 200
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain("<h1>Crystal Mine</h1>")
    end
  end

  it "renders /github" do
    empty_db_fixture(cleanup: true) do
      get "/github/szabgab/crystal-mine.cr"
      response.status_code.should eq 404
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain(%{We don't know about this project})
    end
  end

end

describe "Web Application with content" do
  it "renders /" do
    db_fixture(cleanup: true) do
      get "/"
      # puts response # HTTP::Client::Response  https://crystal-lang.org/api/HTTP/Client/Response.html
      response.status_code.should eq 200
      #puts response.status_message
      #puts response.headers
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain("<h1>Crystal Mine</h1>")
    end
  end

  it "renders /github" do
    db_fixture(cleanup: true) do
      get "/github/szabgab/crystal-mine.cr"
      response.status_code.should eq 200
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain(%{<a href="https://github.com/szabgab/crystal-mine.cr">szabgab/crystal-mine.cr</a>})
    end
  end

  it "renders /github" do
    db_fixture(cleanup: true) do
      get "/github/szabgab/no-such-repo"
      response.status_code.should eq 404
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain(%{We don't know about this project})
    end
  end

end
