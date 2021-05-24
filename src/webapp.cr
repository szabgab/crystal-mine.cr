require "kemal"
require "./mine/db"


get "/" do
  render "src/views/main.ecr", "src/views/layouts/layout.ecr"
end


get "/github/:user_name/:repo_name" do |env|
  host = "github.com"
  user_name = env.params.url["user_name"]
  repo_name = env.params.url["repo_name"]
  project = get_project(host, user_name, repo_name)
  if project.empty?
    halt env, status_code: 404, response: "We don't know about this project"
  end
  render "src/views/shard.ecr", "src/views/layouts/layout.ecr"
end

Kemal.run
