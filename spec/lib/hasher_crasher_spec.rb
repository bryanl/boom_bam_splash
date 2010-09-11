require 'spec_helper'

module HasherCrasher
  class Dummy
    include HasherCrasher::Ohm
    validates :name, :presence => true
  end

  class DummyWithCallBacks
    include HasherCrasher::Ohm

    before_create :prepend_to_name

    private

    def prepend_to_name
      self.name = "prefix-#{name}"
    end
  end
end


describe HasherCrasher::Dummy do
  it_should_behave_like AnActiveModel

  let(:redis) { stub('redis') }

  before do
    $redis = redis
  end

  describe "class" do
    subject { HasherCrasher::Dummy }
    it "should define a namespace" do
      subject.namespace.should == "hasher_crasher_dummy" 
    end

    it "should use the system defined redis" do
      subject.redis.should == redis
    end

    describe "finding" do
      it "should find an instance by name" do
        redis.should_receive(:get).with("hasher_crasher_dummy:key").and_return("data")
        subject.find("key")    
      end

      context "and it exists" do
        before do
          redis.should_receive(:get).with("hasher_crasher_dummy:key").and_return("data")
        end

        it "should return an instance of HasherCrasher::Dummy" do
          subject.find("key").should be_instance_of HasherCrasher::Dummy
        end
      end

      context "and it doesn't exist" do
        before do
          redis.should_receive(:get).with("hasher_crasher_dummy:key").and_return(nil)
        end

        it "should return nil" do
          subject.find("key").should be_nil
        end
      end

    end
  end

  describe "instance" do
    let(:dummy) { HasherCrasher::Dummy.new }


    describe "saving" do
      context "and it is new" do
        before do
          redis.should_receive(:get).with("key").and_return(true)
        end

        it "should save to redis using the name and data" do
          redis.should_receive(:set).with("key", "data")
          dummy.name = "key"
          dummy.data = "data"
          dummy.save
        end
      end

      #it "should have validations" do
        #redis.should_not_receive(:set)
        #dummy.datkka = "data"
        #dummy.save.should_not be_true
      #end

    end

  end

end

describe HasherCrasher::DummyWithCallBacks do
  let(:dummy) { HasherCrasher::DummyWithCallBacks.new }
  let(:redis) { stub('redis') }

  before do
    $redis = redis
  end

  describe "when creating" do
    before do
      redis.should_receive(:get).with("key").and_return(nil)
    end

    it "should run the callback" do
      redis.should_receive(:set).with("hasher_crasher_dummy_with_call_backs:prefix-key", "data")
      dummy.name = "key"
      dummy.data = "data"
      dummy.save
    end
  end
end

