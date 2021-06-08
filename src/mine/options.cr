require "option_parser"

class Options
    class_property verbose      = false
    class_property url          = ""
    class_property repos_file   = ""
    class_property limit        = 0
    class_property sleep        = 0
    class_property recent       = 0
    class_property dependencies = false
    class_property all          = false
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

    myparser = OptionParser.parse do |parser|
        parser.banner = "Usage: miner.cr [arguments]"
        parser.on("--verbose", "Verbose mode") { Options.verbose = true }
        parser.on("--recent=NUMBER", "Recently updated shards") { |value| Options.recent = value.to_i }
        parser.on("--sleep=SECONDS", "How much to wait between processing shards") { |value| Options.sleep = value.to_i }
        parser.on("--limit=LIMIT", "How many URLs to process?") { |value| Options.limit = value.to_i }
        parser.on("--url=URL", "Process this GitHub URL") { |value| Options.url = value }
        parser.on("--repos=PATH", "Process GitHub URLs listed in this file") { |value| Options.repos_file = value }
        parser.on("--dependencies", "Process dependencies") { Options.dependencies = true }
        parser.on("--all", "Process all the shards from GitHub") { Options.all = true }
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
    if Options.url == "" && Options.repos_file == "" && Options.recent == 0 && ! Options.all && ! Options.dependencies
        STDERR.puts "ERROR: Either --url, --repos, --recent, --all, or --dependencies is required"
        STDERR.puts myparser
        exit(1)
    end
end
