require "./spec_helper"
require "../src/collect"
require "../src/mine/tools"


describe "Collect" do
    it "nothing" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr" ])
            stderr.should contain("ERROR: Either --url, --repos, --recent, --all, or --dependencies is required")
            stdout.should eq ""
            exit_code.should eq 256
            File.exists?(ENV["MINE_DB"]).should be_false
        end
    end

    it "one entry after creating db" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr", "--url", "https://github.com/szabgab/crystal-mine.cr" ])
            stderr.should eq ""
            stdout.should eq ""
            exit_code.should eq 0
            res = get_all()
            clean(res)
            expected = [full_database[0]]
            clean(expected)
            res.should eq expected
        end
    end

    it "one entry using all and limit after creating db" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr", "--all", "--limit", "2" ])
            stderr.should eq ""
            stdout.should eq ""
            exit_code.should eq 0
            res = get_all()
            res.size().should eq 2
        end
    end


    it "one entry into existing database where entry already exists" do
        db_fixture(cleanup: true) do
            res = get_all()
            clean(res)
            expected = full_database
            clean(expected)
            res.should eq expected

            stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr", "--url", "https://github.com/szabgab/crystal-mine.cr" ])
            stderr.should eq ""
            stdout.should eq ""
            exit_code.should eq 0
            res = get_all()
            clean(res)
            res.should eq expected
        end
    end

    it "from repos.txt file into empty database" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr", "--repos", "spec/repos.txt" ])
            stderr.should eq ""
            stdout.should eq ""
            exit_code.should eq 0
            res = get_all()
            clean(res)
            expected = full_database
            clean(expected)
            res.should eq expected
        end
    end

end
