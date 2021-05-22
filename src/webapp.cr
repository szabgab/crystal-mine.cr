require "kemal"
require "./mine/db"


get "/" do
  "<h1>Crystal Mine</h1>"
end



get "/github/:user_name/:repo_name" do |env|
  host = "github.com"
  user_name = env.params.url["user_name"]
  repo_name = env.params.url["repo_name"]
  project = get_project(host, user_name, repo_name)
  if project.empty?
    halt env, status_code: 404, response: "We don't know about this project"
  end

  %{<a href="https://github.com/#{user_name}/#{repo_name}">#{user_name}/#{repo_name}</a>}
end

Kemal.run
