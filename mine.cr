require "octokit"

main


def main
    username, token = read_config
    github = Octokit.client(username, token)
    #puts github
    #pp github.user
    pp github.search_repositories "crystal", per_page: 3 #, sort: "updated"
    #pp github.search_users "szabgab"

end

def read_config
    config_file = "config.txt"
    line = File.read_lines(config_file).first
    username, token = line.split(":")
    return username, token
end
