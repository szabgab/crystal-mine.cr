require "./spec_helper"

describe "Database" do
    it "get_all" do
        empty_db_fixture(cleanup: true) do
            res = get_all()
            res.empty?.should be_true
        end

        db_fixture(cleanup: true) do
            expected = [{"id" => 3, "host" => "github.com"}, {"id" => 4, "host" => "github.com"}, {"id" => 1, "host" => "github.com"}, {"id" => 2, "host" => "github.com"}]
            res = get_all()
            #puts res
            res.should eq expected
        end
    end


    it "get_project" do
      db_fixture(cleanup: true) do
        proj = get_project("other", "szabgab", "crystal-mine.cr")
        proj.empty?.should be_true


        proj = get_project("github.com", "szabgab", "crystal-mine.cr")
        exp = {"id" => 1, "host" => "github.com"}
        proj.should eq exp
      end
    end
end
