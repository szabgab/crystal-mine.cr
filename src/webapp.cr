require "kemal"
#require "./mine/db"


get "/" do
  "Hello World!"
end

# get "/github/:user_name/:repo_name" do |env|
#   user_name = env.params.url["user_name"]
#   repo_name = env.params.url["repo_name"]
#   %{<a href="https://github.com/#{user_name}/#{repo_name}">#{user_name}/#{repo_name}</a>}
# end

Kemal.run
