require "octokit"
require "log"
require "uri"
require "option_parser"
require "yaml"


main


def main
    Log.info { "Start running" }
    verbose, limit, keep, url, repos_file = get_options
    if verbose
        Log.setup(:trace)
    end

    #get_repos
    root = File.tempname
    FileUtils.mkdir(root)
    counter = 0
    Log.info { "Root directory #{root}" }
    if ! url.nil?
        process_wrapper url, root
    elsif ! repos_file.nil?
        repos = File.read_lines(repos_file)
        repos.each {|repo|
            counter += 1
            if 0 < limit && limit < counter
                break
            end
            process_wrapper repo, root
        }
    else
        Log.error { "Neither --url nor --repos was provided}" }
    end


    if ! keep
        FileUtils.rm_rf(root)
    end

end


def get_repos
    #username, token = read_config
    #github = Octokit.client(username, token)
    #puts github
    #pp github.user
    #pp github.search_repositories "crystal", per_page: 3 #, sort: "updated"
    #pp github.search_users "szabgab"
end

def process_wrapper(url, root)
        process url, root
    rescue err
        Log.error { "There was an exception in #{url} #{err}" }
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
    if exit_code != 0
        Log.error { "Exit code #{exit_code}" }
        Log.error { "STDERR #{error}" }
        Log.error { "STDOUT #{output}" }
        return
    end

    Log.info { "Deal with repo" }
    # check for certain files (.travis.yml, .github/workflows/*.yml)
    data = {
        "travis_ci"      => false,
        "github_actions" => false,
        "shard_yml"      => false,
    }
    Log.info { Path.new(path, ".travis.yml").to_s }
    data["travis_ci"] = File.exists?(Path.new(path, ".travis.yml").to_s)
    # TODO: Github Actions check if there are *.yml or *.yaml files in the directory?
    data["github_actions"] = File.exists?(Path.new(path, ".github", "workflows").to_s)

    shard_yml = Path.new(path, "shard.yml").to_s
    data["shard_yml"] = File.exists?(shard_yml)

    Log.info { "Handling shard.yml" }
    if File.exists?(shard_yml)
        shards = File.open(shard_yml) do |file|
            YAML.parse(file)
        end
        Log.info { shards }
        Log.info { shards["name"] }
        Log.info { shards.as_h.has_key?("description") ? shards["description"] : "" }
        Log.info { shards["dependencies"] }
        # development_dependencies
        Log.info { shards["version"] }
        Log.info { shards["authors"] }
    end
    Log.info { data }

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

def get_options
    verbose = false
    limit = 0
    keep = false
    url = nil
    repos_file = nil

    OptionParser.parse do |parser|
        parser.banner = "Usage: miner.cr [arguments]"
        parser.on("-v", "--verbose", "Verbose mode") { verbose = true }
        parser.on("--keep", "Keep temporary directory") { keep = true }
        parser.on("--limit=LIMIT", "How many URLs to process?") { |value| limit = value.to_i }
        parser.on("--url=URL", "Process this GitHub URL") { |value| url = value }
        parser.on("--repos=PATH", "Process GitHub URLs listed in this file") { |value| repos_file = value }
        parser.on("-h", "--help", "Show this help") do
            puts parser
            exit
        end
        parser.invalid_option do |flag|
            STDERR.puts "ERROR: #{flag} is not a valid option."
            STDERR.puts parser
            exit(1)
        end
        parser.missing_option do |flag|
            STDERR.puts "ERROR: #{flag} requires a value"
            STDERR.puts parser
            exit(1)
        end
    end
    return verbose, limit, keep, url, repos_file
end
