require "http/client"
require "json"
#require "html"

alias Owner = NamedTuple(
    login: String,
    avatar_url: String,
)

alias GitHubRepo = NamedTuple(
    description: String|Nil,
    forks: Int32,
    full_name: String,
    html_url: String,
    name: String,
    owner: Owner,
    private: Bool,
    pushed_at: Time,
    stargazers_count: Int32,
)

# repo.name
# repo.html_url
# repo.latest_release
# repo.description
# repo.stargazers_count
# repo.pushed_at      Time::Format.new("%FT%TZ")


# HTML.escape
# HTML.escape(Emoji.emojize(description))

alias GitHubRepos = NamedTuple(
    total_count: Int32,
    incomplete_results: Bool,
    items: Array(GitHubRepo),
)

alias User = NamedTuple(
    avatar_url: String,
    bio: String|::Nil,
    company: String|::Nil,
    email: String|::Nil,
    followers: Int32,
    following: Int32,
    gravatar_id: String,
    id: Int64,
    location: String|::Nil,
    login: String,
    name: String|::Nil,
    public_repos: Int32,
    type: String,
)

alias Release = NamedTuple(
    url: String,
    tag_name: String,
    name: String,
    published_at: Time,
    body: String,
)

alias Releases = Array(Release)

alias Tag =  NamedTuple(
    name: String,
    # ...
)

alias Tags = Array(Tag)

# repo.owner.login
# repo.owner.avatar_url


class GitHub
    def initialize(github_user : String, github_token : String)
        @github_user = github_user
        @github_token = github_token
    end

    def get_repos(per_page = 3, page = 1, sort = "updated")
        query = "language:crystal"
        # per_page max is 100
        # sort can be stars, forks, help-wanted-issues, updated
        order = "desc"
        response = fetch("/search/repositories?q=#{query}&per_page=#{per_page}&sort=#{sort}&page=#{page}&orde=#{order}")
        repos = GitHubRepos.from_json(response.body)
        return repos
    end

    def get_user(username)
        response = fetch("/users/#{username}")
        user = User.from_json(response.body)
        return user
    end

    def get_releases(full_name)
        response = fetch("/repos/#{full_name}/releases")
        if response.body == "[]"
            return [] of Release
        end
        releases = Releases.from_json(response.body)
        return releases
    end
    def get_tags(full_name)
        response = fetch("/repos/#{full_name}/tags")
        if response.body == "[]"
            return [] of Tag
        end
        tags = Tags.from_json(response.body)
        return tags
    end

    def _latest_release(full_name)
        releases = get_releases(full_name)
        if releases.size > 0
            return releases[0]["name"]
        end
        tags = get_tags(full_name)
        if tags.size > 0
            return tags[0]["name"]
        end
        return ""
    end

    def get_repo_details(full_name)
        response = fetch("/repos/#{full_name}")
        puts response.body
        # if response.body == "[]"
        #     return [] of Release
        # end
        # releases = Releases.from_json(response.body)
    end

    def fetch(url)
        client = HTTP::Client.new("api.github.com", 443, true)
        client.basic_auth @github_user, @github_token
        response = client.get(url)
        # puts response.body
        return response
    end

end


# gh = GitHub.new(ENV["GITHUB_USER"], ENV["GITHUB_TOKEN"])
# puts gh.get_user("arielszabo")
# puts gh.get_repos
# puts gh.get_releases("iv-org/invidious")
# puts gh._latest_release("iv-org/invidious")
# puts gh._latest_release("szabgab/crystal-mine.cr")
# puts gh._latest_release("szabgab/test-class")
# gh.get_repo_details("szabgab/test-class")
