require "./spec_helper"

# updated the data for the tests

no_db_fixture(cleanup: true) do
    puts ENV["MINE_DB"]

    stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr", "--repos", "spec/repos.txt" ])
    stderr.should eq ""
    stdout.should eq ""
    exit_code.should eq 0

    `echo .dump | sqlite3 #{ENV["MINE_DB"]} > spec/data.sql`
end
