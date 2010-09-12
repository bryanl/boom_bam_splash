require 'spec_helper'

describe '/sounds/index' do

  before(:each) do
    render '/sounds/index'
  end

  it 'should have a link to create a new sound' do
    response.should have_tag("a", :text => "Add a new sound")
  end

end
