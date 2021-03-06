require "octokit"
require "log"
require "uri"
require "yaml"
require "file_utils"
require "../lib/shards/src/spec"
require "./mine/db"
require "./mine/github"
require "./mine/options"
require "./mine/tools"

def mine
    get_options
    setup_logging
    create_db

    if ! ENV.has_key?("MINE_DATA")
        raise "MINE_DATA is missing"
    end
    root = ENV["MINE_DATA"]
    if ! File.exists?(root)
        raise "#{root} does not exist"
    end

    Log.info { "Root directory #{root}" }
    if Options.url != ""
        process_by_url(Options.url, root)
    elsif Options.repos_file != ""
        process_repos_file(root)
    elsif Options.recent > 0
        process_recent_shards(root)
    elsif Options.all
        process_all_shards(root)
    else
        Log.error { "Neither --url nor --repos not --recent was provided}" }
    end

    if Options.dependencies
        process_dependencies(root)
    end
end

def setup_logging
    if Options.verbose
        Log.setup(:trace)
    else
        Log.setup(:warn)
    end
end

def process_repos_file(root)
    repos = File.read_lines(Options.repos_file)
    counter = 0
    repos.each {|repo_url|
        counter += 1
        if 0 < Options.limit && Options.limit < counter
            break
        end
        process_by_url(repo_url, root)
        if Options.sleep != 0
            sleep(Options.sleep)
        end
    }
end

def process_by_url(repo_url, root)
    host, user_name, repo_name = parse_url(repo_url)
    Log.debug { host }

    username, token = read_config
    gh = GitHub.new(username, token)

    repo = gh.get_repo_details("#{user_name}/#{repo_name}")

    process_wrapper(repo, repo_url, root)
end

def process_all_shards(root)
    username, token = read_config
    gh = GitHub.new(username, token)
    counter = 0
    start_time = Time.utc

    "abcdefghijklmnopqruvwxyz".each_char {|chr|
        page = 1
        loop do
            if page > 10
                # https://docs.github.com/v3/search/
                Log.info { "Only the first 1000 search results are available. We are done with letter #{chr}"}
                break
            end
            query = "language:crystal+#{chr}"
            Log.info { "Fetching page #{page} for '#{query}'" }
            repos = gh.get_repos query: query, per_page: 100, page: page, sort: "updated"
            if ! repos.has_key?("total_count")
                Log.error { %{Missing total_count} }
                Log.error { %{Received: #{repos}} }
                break
            end
            Log.info { %{Received size: #{repos["items"].size} Total count: #{repos["total_count"]}} }
            res = repos["items"].each {|repo|
                counter += 1
                current_time = Time.utc
                Log.info { "Processing item #{counter} Elapsed time: #{current_time-start_time}" }
                if 0 < Options.limit && Options.limit < counter
                    Log.info { %{Limit of #{Options.limit} was reached by counter: #{counter}} }
                    break "done"
                end
                if repos["total_count"] < counter
                    Log.info { %{Total count of #{repos["total_count"]} was reached by counter: #{counter}} }
                    break "done"
                end
                if repos["items"].size == 0
                    Log.info { %{No items were received at counter: #{counter}} }
                    break "done"
                end
                process_wrapper(repo, repo["html_url"], root)
                if Options.sleep != 0
                    sleep(Options.sleep)
                end
            }
            if res == "done"
                break
            end
            page += 1
        end
    }
    end_time = Time.utc
    Log.info { "Total Elapsed time: #{end_time-start_time}" }
end

def process_recent_shards(root)
    username, token = read_config
    gh = GitHub.new(username, token)
    # here we assume that the "recent" passed to options is less than 100, the max page size allowed by GitHub API
    repos = gh.get_repos per_page: Options.recent

    counter = 0
    repos["items"].each {|repo|
        counter += 1
        if 0 < Options.limit && Options.limit < counter
            break
        end
        process_wrapper(repo, repo["html_url"], root)
        if Options.sleep != 0
            sleep(Options.sleep)
        end
    }
end

def process_dependencies(root)
    # get all the shards that are listed as dependencies
    # go over them and if they are not in the database try to add them to the database
    # do this again and again till we processed all the missing dependencies
    # keep a list of the ones that are not available to avoid infinite try. Later add this information to the database
    processed = Set(String).new

    loop do
        newly_processed = false
        dependencies = get_all_dependencies
        dependencies.each {|dep|
            shard = get_project(dep.host, dep.user_name, dep.repo_name)
            #Log.info { shard }
            if shard.nil? && ! processed.includes?(dep.url)
                Log.info { dep.url }
                processed.add(dep.url)
                newly_processed = true
                process_by_url(dep.url, root)
            end
        }
        break if ! newly_processed
    end
end



def process_wrapper(repo, url, root)
    Log.debug { repo }

    process url, root
rescue err
    Log.error { "There was an exception in #{url} #{err}" }
    Log.error { err.backtrace }
end


    # https://github.com/szabgab/crystal-mine.cr
def parse_url(url) : Tuple(String, String, String)
    # TODO check if the URL looks good?
    match = %r{^https?://github.com/[\w.-]+/[\w.-]+$}.match(url)
    if ! match
        Log.error { "URL '#{url}' does not match" }
        raise "URL '#{url}' does not match"
    end

    uri = URI.parse url.gsub(/\.git$/, "")
    host = uri.host.to_s
    user_name, repo_name = uri.path[1..].split("/")
    return host, user_name, repo_name
end

def process(url, root)
    Log.info { "Process URL '#{url}' directory #{root}" }

    host, user_name, repo_name = parse_url(url)

    data = Shard.new
    data.host           = host
    data.user_name      = user_name
    data.repo_name      = repo_name

    # We would like to clone this and make sure it is in a unique directory called github.com/szabgab/crystal-mine.cr
    # As other repositories might have the same name and at one point alternative hosting might be supported as well
    # e.g. GitLab, Bitbucket etc.
    path = Path.new(root, host, user_name).to_s
    FileUtils.mkdir_p(path)
    path = Path.new(path, repo_name).to_s
    clone_repo(url, path, root)
    process_repo(data, path)
    handle_shard_yml(data, path)

    Log.info { "data: #{data}" }
    rows_affected, last_insert_id = store_in_db(data)
    Log.info { "rows_affected: #{rows_affected} last_insert_id #{last_insert_id}" }
end


def process_repo(data, path)
    Log.info { "Deal with repo" }
    # check for certain files (.travis.yml, .github/workflows/*.yml)

    Log.info { Path.new(path, ".travis.yml").to_s }
    data.travis_ci = File.exists?(Path.new(path, ".travis.yml").to_s)
    # TODO: Github Actions check if there are *.yml or *.yaml files in the directory?
    data.github_actions = File.exists?(Path.new(path, ".github", "workflows").to_s)
end


def clone_repo(url, path, root)
    if Options.all && File.exists?(path)
        return
    end
    Log.info { "Downloading #{url} to #{path}" }
    tempdir = File.tempname dir: root
    #FileUtils.mkdir(tempdir)
    #FileUtils.rm_rf(tempdir)
    output, error, exit_code = capture("git", ["clone", "--depth", "1", url, tempdir])
    if exit_code != 0
        Log.error { "Exit code #{exit_code}" }
        Log.error { "STDERR #{error}" }
        Log.error { "STDOUT #{output}" }
        FileUtils.rm_rf(tempdir)
        return
    end
    if File.exists?(path)
        FileUtils.rm_rf(path)
    end
    FileUtils.mv(tempdir, path)
end


def handle_shard_yml(data, path_to_dir)
    Log.info { "Handling shard.yml" }

    shard_yml_file = Path.new(path_to_dir, "shard.yml").to_s
    data.shard_yml = File.exists?(shard_yml_file)
    if ! data.shard_yml
        return
    end

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
