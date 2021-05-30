require "./spec_helper"
require "../src/collect"


describe "Collect" do
    it "collect nothing" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(CRYSTAL, ["src/mine.cr" ])
            stderr.should eq ""
            stdout.should contain("ERROR - Neither --url nor --repos not --recent was provided")
            exit_code.should eq 0 # TODO: probably should be something else
            res = get_all()
            res.empty?.should be_true
        end
    end

    it "collect one entry after creating db" do
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

    it "collect one entry into existing database where entry already exists" do
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

    it "collect from repos.txt file into empty database" do
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
