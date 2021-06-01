require "kemal"
require "./mine/db"
#require "digest/md5"
#email = ARGV[0]
#code = Digest::MD5.hexdigest(email)
#puts "https://www.gravatar.com/avatar/#{code}?s=100&d=blank"

base_url = "https://crystal-mine.org"
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
    xml += %{    <loc>#{base_url}/#{shard["host"]}/#{shard["user_name"]}/#{shard["repo_name"]}</loc>\n}
    #time = Time.parse(shard["record_last_updated"], "%Y-%m-%d %H:%M:%S.%z", Time::Location::UTC)
    #xml += %{    <lastmod>#{shard["record_last_updated"]}</lastmod>\n}
    xml += %{  </url>\n}
  }
  xml += %{</urlset>\n};
  xml
end


Kemal.run
