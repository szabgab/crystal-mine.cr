require "./spec_helper"

describe "Web Application with empty database" do
  it "renders /" do
    empty_db_fixture(cleanup: true) do
      get "/"
      response.status_code.should eq 200
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain("<title>Welcome to the Crystal Mine</title>")
      response.body.should contain(%{<h1 class="title">Welcome to the Crystal Mine</h1>})
    end
  end

  it "renders /about" do
    empty_db_fixture(cleanup: true) do
      get "/about"
      response.status_code.should eq 200
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain("<title>About Crystal Mine</title>")
      response.body.should contain("<h1>About Crystal Mine</h1>")
      #puts response.body # TODO check title
    end
  end

  it "renders /github" do
    empty_db_fixture(cleanup: true) do
      get "/github.com/szabgab/crystal-mine.cr"
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
      response.body.should contain("<title>Welcome to the Crystal Mine</title>")
      response.body.should contain(%{<h1 class="title">Welcome to the Crystal Mine</h1>})
      response.body.should contain(%{<li><a href="/github.com/szabgab/crystal-mine.cr">szabgab/crystal-mine.cr</a> - Crystal Mine</li>})
      #puts response.body
    end
  end

  it "renders /github.com/szabgab/crystal-mine.cr as regular page" do
    db_fixture(cleanup: true) do
      get "/github.com/szabgab/crystal-mine.cr"
      response.status_code.should eq 200
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain("<title>szabgab/crystal-mine.cr</title>")
      response.body.should contain(%{<a href="https://github.com/szabgab/crystal-mine.cr">szabgab/crystal-mine.cr</a>})
    end
  end

  it "renders /github.com/szabgab/no-such-repo as 404 page" do
    db_fixture(cleanup: true) do
      get "/github.com/szabgab/no-such-repo"
      response.status_code.should eq 404
      response.headers["Content-Type"].should eq "text/html"
      response.body.should contain(%{We don't know about this project})
    end
  end

end
