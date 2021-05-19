require "octokit"

main


def main
    token = read_config
    github = Octokit.client("szabgab", token)
    #puts github
    #pp github.user
    #pp github.search_repositories "perl", per_page: 3 #, sort: "updated"
    pp github.search_users "szabgab"

end

def read_config
    config_file = "config.txt"
    line = File.read_lines(config_file).first
    #puts line
    return line
end
