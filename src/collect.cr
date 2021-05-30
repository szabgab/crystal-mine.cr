require "octokit"
require "log"
require "uri"
require "option_parser"
require "yaml"
require "../lib/shards/src/spec"
require "./mine/db"
require "./mine/github"


class Project
    property host
    getter host : String

    property user_name
    getter user_name : String

    property repo_name
    getter repo_name : String

    property travis_ci
    getter travis_ci : Bool

    property github_actions
    getter github_actions : Bool

    property shard_yml
    getter shard_yml : Bool

    property name
    getter name : String

    property description
    getter description : String

    property version
    getter version : String

    property crystal
    getter crystal : String

    property license
    getter license : String

    property dependencies
    getter dependencies = [] of Array(String)

    def initialize
        @host = ""
        @user_name = ""
        @repo_name = ""
        @travis_ci = false
        @github_actions = false
        @shard_yml = false
        @name = ""
        @description = ""
        @version = ""
        @crystal = ""
        @license = ""
        @dependencies = [] of Array(String)
    end
end

def mine
    options = get_options
    if options.verbose
        Log.setup(:trace)
    else
        Log.setup(:warn)
    end
    create_db

    root = File.tempname
    FileUtils.mkdir(root)
    counter = 0
    Log.info { "Root directory #{root}" }
    if options.url != ""
        process_wrapper options.url, root
    elsif options.repos_file != ""
        repos = File.read_lines(options.repos_file)
        repos.each {|repo|
            counter += 1
            if 0 < options.limit && options.limit < counter
                break
            end
            process_wrapper repo, root
        }
    elsif options.recent
        repos = get_repos
        repos["items"].each {|repo|
            counter += 1
            if 0 < options.limit && options.limit < counter
                break
            end
            #p! repo
            process_wrapper repo["html_url"], root
        }
    else
        Log.error { "Neither --url nor --repos not --recent was provided}" }
    end


    if ! options.keep
        FileUtils.rm_rf(root)
    end

end


def get_repos
    username, token = read_config
    gh = GitHub.new(username, token)
    gh.get_repos
end

def process_wrapper(url, root)
    process url, root
rescue err
    Log.error { "There was an exception in #{url} #{err}" }
    Log.error { err.backtrace }
end


def parse_url(url) : Tuple(String, String, String)
    uri = URI.parse url.gsub(/\.git$/, "")
    host = uri.host.to_s
    user_name, repo_name = uri.path[1..].split("/")
    return host, user_name, repo_name
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
    host, user_name, repo_name = parse_url(url)
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
    data = Project.new
    data.host           = host
    data.user_name      = user_name
    data.repo_name      = repo_name

    Log.info { Path.new(path, ".travis.yml").to_s }
    data.travis_ci = File.exists?(Path.new(path, ".travis.yml").to_s)
    # TODO: Github Actions check if there are *.yml or *.yaml files in the directory?
    data.github_actions = File.exists?(Path.new(path, ".github", "workflows").to_s)

    handle_shard_yml(data, path)

    Log.info { "data: #{data}" }
    rows_affected, last_insert_id = store_in_db(data)
    Log.info { "rows_affected: #{rows_affected} last_insert_id #{last_insert_id}" }
end

def handle_shard_yml(data, path_to_dir)
    Log.info { "Handling shard.yml" }

    shard_yml_file = Path.new(path_to_dir, "shard.yml").to_s
    data.shard_yml = File.exists?(shard_yml_file)

    shard = Shards::Spec.from_file(path_to_dir) # validate = true

    data.name = shard.name || ""
    data.description = shard.description || ""
    data.version = shard.version.to_s || "" # (Shards::Version | String)
    data.crystal = shard.crystal || "" # ">=0.36.1, < 2.0.0"
    data.license = shard.license || ""
    # TODO: targets, scripts

    shard.dependencies.each {|dep|
        #puts "  #{dep.name}"
        host, user_name, repo_name = parse_url(dep.resolver.source) #  https://github.com/crystal-ameba/ameba.git
        data.dependencies.push(["dependencies", host, user_name, repo_name])
        #puts "  #{dep.requirement}"
    }
    shard.development_dependencies.each {|dep|
        #puts "  #{dep.name}"
        host, user_name, repo_name = parse_url(dep.resolver.source) #  https://github.com/crystal-ameba/ameba.git
        data.dependencies.push(["development_dependencies", host, user_name, repo_name])
        #puts "  #{dep.requirement}"
    }

    #data.authors = [] of Array(Hash(String, String))
    shard.authors.each {|author|
        Log.info { "author: #{author.name}  #{author.email}" }
        # data["authors"].push({
        #     "name" => author.name,
        #     "email" => author.email,
        # })
    }
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

def read_config : Tuple(String, String)
    config_file = "config.txt"
    line = File.read_lines(config_file).first
    username, token = line.split(":")
    return username, token
end

class Options
    property verbose
    getter verbose : Bool

    property url
    getter url : String

    property repos_file
    getter repos_file : String

    property limit
    getter limit : Int32

    property keep
    getter keep : Bool

    property recent
    getter recent : Bool

    def initialize(
            verbose : Bool = false ,
            github_token : String = "",
            limit : Int32 = 0,
            keep : Bool = false,
            url : String  = "",
            repos_file : String = "",
            recent : Bool = false,
        )
        @verbose = verbose
        @recent = recent
        @github_token = github_token
        @limit = limit
        @keep = keep
        @url = url
        @repos_file = repos_file
    end
end

def get_options
    # --recent  fetch the most recently changed repositories and work on them
    # Should it get a date so we only check repositories changed since that date?
    # might need paging if there are more than 100 recently updated repositories
    # --all fetch all the repositories (use paging to go beyond the 100 limit)
    # and update all of them. This can be used when we checnge the schema and would like
    # to update all the data
    # Have some mechanism to work slowly so we won't go beyond the accepted request rate of GitHub.

    # -- people ? A separate flag to upadte all the authors or should this be part of our regular update


    # store the start date of our current update process and only update records that have not been updated since
    # that time to avoid updating the same record because multiple occurance (especially about people.)

    options = Options.new

    OptionParser.parse do |parser|
        parser.banner = "Usage: miner.cr [arguments]"
        parser.on("-v", "--verbose", "Verbose mode") { options.verbose = true }
        parser.on("--recent", "Recently updated shards") { options.recent = true }
        parser.on("--keep", "Keep temporary directory") { options.keep = true }
        parser.on("--limit=LIMIT", "How many URLs to process?") { |value| options.limit = value.to_i }
        parser.on("--url=URL", "Process this GitHub URL") { |value| options.url = value }
        parser.on("--repos=PATH", "Process GitHub URLs listed in this file") { |value| options.repos_file = value }
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
    return options
end
