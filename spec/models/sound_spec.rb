require 'spec_helper'

describe Sound do
  describe "when saving" do
    it "should shove the guts of data_file in to data" do
      fixture_file = File.join(Rails.root, "spec/fixtures/data.txt")
      sound = Sound.new :name => "test", :data_file => File.new(fixture_file)
      sound.data.should == "this is data.txt\n"
    end
  end
end
