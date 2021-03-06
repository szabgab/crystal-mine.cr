require "kemal"
require "./mine/db"
#require "digest/md5"
#email = ARGV[0]
#code = Digest::MD5.hexdigest(email)
#puts "https://www.gravatar.com/avatar/#{code}?s=100&d=blank"

base_url = "https://crystal-mine.org"
title = ""
query = ""
class HTTP::Server::Context
  getter start_time : Time::Span = Time.monotonic
end

get "/" do |env|
  title = "Welcome to the Crystal Mine"
  render "src/views/main.ecr", "src/views/layouts/layout.ecr"
end

get "/about" do |env|
  render "src/views/about.ecr", "src/views/layouts/layout.ecr"
end

get "/stats" do |env|
  stats = get_stats
  render "src/views/stats.ecr", "src/views/layouts/layout.ecr"
end

get "/stats/versions" do |env|
  crystal_versions, other_crystal_versions = get_crystal_versions
  render "src/views/crystal_versions.ecr", "src/views/layouts/layout.ecr"
end

get "/stats/licenses" do |env|
  licenses = get_licenses
  render "src/views/licenses.ecr", "src/views/layouts/layout.ecr"
end

get "/search" do |env|
  query = env.params.query.has_key?("query") ? env.params.query["query"] : ""
  special = env.params.query.has_key?("special") ? env.params.query["special"] : ""
  crystal_version = env.params.query.has_key?("crystal") ? env.params.query["crystal"] : ""
  page = begin env.params.query["page"].to_i rescue 1 end
  size = begin env.params.query["size"].to_i rescue 10 end
  shards, total = get_shards(query, special, limit = size, offset = (page-1)*size)
  previous_page = page > 1 ? page - 1 : 0
  number_of_pages = (total / size).ceil.to_i
  next_page = page < number_of_pages ? page + 1 : number_of_pages

  render "src/views/list.ecr", "src/views/layouts/layout.ecr"
end

# github.com nothing special is shown as right now everything is from github.com
get "/github.com" do |env|
  render "src/views/main.ecr", "src/views/layouts/layout.ecr"
end

# list all the projects of a user
get "/github.com/:user_name" do |env|
  host = "github.com"
  user_name = env.params.url["user_name"]
  shards = get_shards_of_user(host, user_name)
  render "src/views/user.ecr", "src/views/layouts/layout.ecr"
end

get "/github.com/:user_name/:repo_name" do |env|
  host = "github.com"
  user_name = env.params.url["user_name"]
  repo_name = env.params.url["repo_name"]
  title = "#{user_name}/#{repo_name}"
  shard = get_project(host, user_name, repo_name)
  if shard.nil?
    halt env, status_code: 404, response: "We don't know about this project"
  end
  all_dependencies = get_dependencies(shard.id)
  dependencies = all_dependencies.reject do |dep| dep.dependency_type != "dependencies" end
  development_dependencies = all_dependencies.reject do |dep| dep.dependency_type != "development_dependencies" end
  reverse_dependencies = get_reverse_dependencies(host, user_name, repo_name)
  src = File.exists?(Path.new(ENV["MINE_DATA"], host, user_name, repo_name))

  render "src/views/shard.ecr", "src/views/layouts/layout.ecr"
end

# source
get "/github.com/:user_name/:repo_name/source/*all" do |env|
  filepath = env.params.url["all"]
  if filepath[0..4] == ".git/"
    halt env, status_code: 404, response: "We don't have this file #{filepath}"
  end

  host = "github.com"
  user_name = env.params.url["user_name"]
  repo_name = env.params.url["repo_name"]
  src = Path.new(ENV["MINE_DATA"], host, user_name, repo_name, filepath).to_s
  if ! File.exists?(src)
    halt env, status_code: 404, response: "We don't have this file #{src}"
  end

  Log.info { "source #{src}" }
  if File.directory?(src)
    if filepath != "" && filepath[-1] != "/"
      filepath += "/"
    end
    entries = Dir.entries(src.to_s).sort.reject { |entry| entry == ".." || entry == "." || entry == ".git" }
    render "src/views/directory.ecr", "src/views/layouts/layout.ecr"
  else
    if src.downcase =~ /\.(png|ico|jpg|jpeg)$/
      file_content = ""
      image_path = "/github.com/#{user_name}/#{repo_name}/raw/#{filepath}"
    else
      file_content = File.read(src)
      image_path = ""
    end
    render "src/views/file.ecr", "src/views/layouts/layout.ecr"
  end
end

# raw
get "/github.com/:user_name/:repo_name/raw/*all" do |env|
  filepath = env.params.url["all"]
  if filepath[0..4] == ".git/"
    halt env, status_code: 404, response: "We don't have this file #{filepath}"
  end

  host = "github.com"
  user_name = env.params.url["user_name"]
  repo_name = env.params.url["repo_name"]
  src = Path.new(ENV["MINE_DATA"], host, user_name, repo_name, filepath).to_s
  if ! File.exists?(src)
    halt env, status_code: 404, response: "We don't have this file #{src}"
  end

  Log.info { "raw #{src}" }
  if File.directory?(src)
    halt env, status_code: 404, response: "We don't have this directory #{src}"
  else
    send_file env, src
  end
end


get "/robots.txt" do |env|
  env.response.content_type = "text/plain"
  <<-ROBOTS
    Sitemap: #{base_url}/sitemap.xml

    User-agent: *

    ROBOTS
end

get "/sitemap.xml" do |env|
  now = Time.utc
  now_str = now.to_s("%Y-%m-%d")
  env.response.content_type = "application/xml"
  xml = %{<?xml version="1.0" encoding="UTF-8"?>\n}
  xml += %{<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n}
  pages = ["", "about", "stats"]
  pages.each {|page|
    xml += %{  <url>\n}
    xml += %{    <loc>#{base_url}/#{page}</loc>\n}
    xml += %{    <lastmod>#{now_str}</lastmod>\n}
    xml += %{  </url>\n}
  }
  shards = get_all
  shards.each {|shard|
    xml += %{  <url>\n}
    xml += %{    <loc>#{base_url}/#{shard.host}/#{shard.user_name}/#{shard.repo_name}</loc>\n}
    #time = Time.parse(shard.record_last_updated, "%Y-%m-%d %H:%M:%S.%z", Time::Location::UTC)
    #xml += %{    <lastmod>#{shard.record_last_updated}</lastmod>\n}
    xml += %{  </url>\n}
  }
  xml += %{</urlset>\n};
  xml
end


Kemal.run
