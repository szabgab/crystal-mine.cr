require "./spec_helper"

describe "Database" do
    it "get_project" do
      fixture(cleanup: true) do
        proj = get_project("other", "szabgab", "crystal-mine.cr")
        proj.should eq {}


        proj = get_project("github.com", "szabgab", "crystal-mine.cr")
        exp = {"id" => 1, "host" => "github.com"}
        proj.should eq exp
      end
    end
end  
  