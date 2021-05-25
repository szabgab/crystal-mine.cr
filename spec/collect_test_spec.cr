require "./spec_helper"
require "../src/collect"

# TODO is there some way to get to the current crystal executable?
crystal = "crystal"

def clean(items)
    items.each {|item|
        item.delete("record_last_updated")
    }
end

describe "Collect" do
    it "collect nothing" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(crystal, ["src/mine.cr" ])
            exit_code.should eq 0 # TODO: probably should be something else
            stderr.should eq ""
            stdout.should contain("ERROR - Neither --url nor --repos was provided")
            res = get_all()
            res.empty?.should be_true
        end
    end

    it "collect one entry after creating db" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(crystal, ["src/mine.cr", "--url", "https://github.com/szabgab/crystal-mine.cr" ])
            exit_code.should eq 0
            stderr.should eq ""
            stdout.should eq ""
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
            res.should eq full_database

            stdout, stderr, exit_code = capture(crystal, ["src/mine.cr", "--url", "https://github.com/szabgab/crystal-mine.cr" ])
            exit_code.should eq 0
            stderr.should eq ""
            stdout.should eq ""
            res = get_all()
            clean(res)
            expected = full_database
            clean(expected)
            res.should eq expected
        end
    end

    it "collect from repos.txt file into empty database" do
        no_db_fixture(cleanup: true) do
            stdout, stderr, exit_code = capture(crystal, ["src/mine.cr", "--repos", "spec/repos.txt" ])
            exit_code.should eq 0
            stderr.should eq ""
            stdout.should eq ""
            res = get_all()
            clean(res)
            expected = full_database
            clean(expected)
            res.should eq expected
        end
    end


end
