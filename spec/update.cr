require "./spec_helper"
require "../src/mine/db"
# updated the data for the tests


["repos", "many_repos"].each {|name| 
    no_db_fixture(cleanup: true) do
        #puts ENV["MINE_DATA"]
        #puts ENV["MINE_DB"]

        stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr", "--repos", "spec/#{name}.txt" ])
        stderr.should eq ""
        stdout.should eq ""
        exit_code.should eq 0
        File.write("spec/#{name}.json", get_all().to_json)

        `echo .dump | sqlite3 #{ENV["MINE_DB"]} > spec/#{name}.sql`
    end
}