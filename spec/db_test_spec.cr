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
            clean(res)
            expected = full_database
            clean(expected)
            res.should eq expected
        end
    end


    it "get_project" do
      db_fixture(cleanup: true) do
        proj = get_project("other", "szabgab", "crystal-mine.cr")
        proj.nil?.should be_true


        proj = get_project("github.com", "szabgab", "crystal-mine.cr")
        clean([proj])
        expected = full_database
        clean(expected)
        proj.should eq expected[0]
      end
    end
end
