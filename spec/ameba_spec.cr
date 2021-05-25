require "spec"

describe "Run ameba" do
    it "Lint code" do
       res = system("./bin/ameba")
       res.should be_true
    end
end
