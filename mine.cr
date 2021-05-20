require "octokit"
require "log"
require "uri"


main


def main
    Log.setup(:trace)
    Log.info { "Start running" }
    #get_repos

    root = File.tempname
    FileUtils.mkdir(root)
    Log.info { "Root directory #{root}" }
    repos = File.read_lines("repos.txt")
    repos.each {|repo|
        begin
            process repo, root
        rescue err
            Log.error { "There was an exception in #{repo}" }
        end
    }
end


def get_repos
    #username, token = read_config
    #github = Octokit.client(username, token)
    #puts github
    #pp github.user
    #pp github.search_repositories "crystal", per_page: 3 #, sort: "updated"
    #pp github.search_users "szabgab"
end


def process(url, root)
    Log.info { "Process URL '#{url}' directory #{root}" }

    # https://github.com/szabgab/crystal-mine.cr

    # TODO check if the URL looks good?
    match = %r{^https?://github.com/[\w.-]+/[\w.-]+$}.match(url)
    if ! match
        Log.error { "URL does not match" }
        return
    end

    # We would like to clone this and make sure it is in a unique directory called github.com/szabgab/crystal-mine.cr
    # As other repositories might have the same name and at one point alternative hosting might be supported as well
    # e.g. GitLab, Bitbucket etc.
    uri = URI.parse url
    host = uri.host.to_s
    user_name, repo_name = uri.path[1..].split("/")
    # puts typeof(root)
    # puts typeof(host)
    # puts typeof(user_name)
    path = Path.new(root, host, user_name).to_s
    FileUtils.mkdir_p(path)
    path = Path.new(path, repo_name).to_s

    # Clone repo
    output, error, exit_code = capture("git", ["clone", "--depth", "1", url, path])
    if exit_code == 0
        Log.error { "Exit code #{exit_code}" }
        Log.error { "STDERR #{error}" }
        Log.error { "STDOUT #{output}" }
        return
    end

    Log.info { "Deal with repo" }
    # check for certain files (.travis.yml, .github/workflows/*.yml)
    # Store in some database
end


def capture(cmd, params)
    process = Process.new(cmd, params,
        output: Process::Redirect::Pipe,
        error: Process::Redirect::Pipe,
        )

    output = process.output.gets_to_end
    error  = process.error.gets_to_end

    res = process.wait

    return output, error, res.exit_status
end

def read_config
    config_file = "config.txt"
    line = File.read_lines(config_file).first
    username, token = line.split(":")
    return username, token
end
