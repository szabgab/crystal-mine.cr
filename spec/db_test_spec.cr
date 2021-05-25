require "./spec_helper"

describe "Database" do
    it "get_all" do
        no_db_fixture(cleanup: true) do
          expect_raises(SQLite3::Exception, "no such table: shards") do
            get_all()
          end
        end

        empty_db_fixture(cleanup: true) do
            res = get_all()
            res.empty?.should be_true
        end

        db_fixture(cleanup: true) do
            res = get_all()
            # puts res
            res.should eq full_database
        end
    end


    it "get_project" do
      db_fixture(cleanup: true) do
        proj = get_project("other", "szabgab", "crystal-mine.cr")
        proj.empty?.should be_true


        proj = get_project("github.com", "szabgab", "crystal-mine.cr")
        #exp = full_database[0]
        proj.should eq full_database[0]
      end
    end
end
