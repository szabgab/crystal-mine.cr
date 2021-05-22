require "./spec_helper"

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
