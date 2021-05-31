require "option_parser"

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
    getter recent : Int32

    def initialize(
            verbose : Bool = false ,
            github_token : String = "",
            limit : Int32 = 0,
            keep : Bool = false,
            url : String  = "",
            repos_file : String = "",
            recent : Int32 = 0,
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
        parser.on("--recent=NUMBER", "Recently updated shards") { |value| options.recent = value.to_i }
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
