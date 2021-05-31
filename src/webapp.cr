require "kemal"
require "./mine/db"
#require "digest/md5"
#email = ARGV[0]
#code = Digest::MD5.hexdigest(email)
#puts "https://www.gravatar.com/avatar/#{code}?s=100&d=blank"

title = ""
query = ""

get "/" do
  title = "Welcome to the Crystal Mine"
  shards = get_all
  render "src/views/main.ecr", "src/views/layouts/layout.ecr"
end

get "/about" do
  render "src/views/about.ecr", "src/views/layouts/layout.ecr"
end

get "/stats" do
  stats = get_stats
  render "src/views/stats.ecr", "src/views/layouts/layout.ecr"
end

get "/search" do |env|
  query = env.params.query["query"]
  shards = get_shards(query)
  render "src/views/main.ecr", "src/views/layouts/layout.ecr"
end


get "/github.com/:user_name/:repo_name" do |env|
  host = "github.com"
  user_name = env.params.url["user_name"]
  repo_name = env.params.url["repo_name"]
  title = "#{user_name}/#{repo_name}"
  shard = get_project(host, user_name, repo_name)
  if shard.empty?
    halt env, status_code: 404, response: "We don't know about this project"
  end
  all_dependencies = get_dependencies(shard["id"])
  dependencies = all_dependencies.reject do |dep| dep.dependency_type != "dependencies" end
  development_dependencies = all_dependencies.reject do |dep| dep.dependency_type != "development_dependencies" end
  reverse_dependencies = get_reverse_dependencies(host, user_name, repo_name)

  render "src/views/shard.ecr", "src/views/layouts/layout.ecr"
end

Kemal.run
