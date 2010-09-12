require 'spec_helper'

describe SoundsController do

  describe "index" do

    let(:sound) { mock_model(Sound) }
    let(:sounds) { [sound] }

    def do_get
      get :index
    end

    before do
      Sound.stub!(:all).and_return([sound])
      do_get
    end

    subject { response } 

    it { should be_success }

    it "should assign to sounds" do
      assigns[:sounds].should == sounds
    end

  end

  describe "new" do
    let(:sound) { mock_model(Sound) }

    def do_get
      get :new
    end

    before do
      Sound.stub!(:new).and_return(sound)
      do_get
    end

    subject { response } 

    it { should be_success }

    it "should assign to sounds" do
      assigns[:sound].should == sound
    end
  end


  describe "create" do
    let(:sound) { mock_model(Sound) }

    def do_post
      post :create, :sound => {:name => "name", :data => "data"}
    end

    before do
      do_post
    end

    subject { response }

    it { should be_redirect }

  end

  describe "show" do
    let(:sound) { mock_model(Sound, :id => 999, :data => "woo woo woo") }

    def do_get
      get :show, :id => "999"
    end

    before do
      Sound.should_receive(:find).with("999").and_return(sound)
      do_get
    end

    subject { response }

    it { should be_success }

    its(:body) { should match /woo woo woo/ }
  end


end
