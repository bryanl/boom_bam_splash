require 'spec_helper'

describe '/sounds/index' do

  before do
    render '/sounds/new'
  end

  it 'should have a link to create a new sound' do
    response.should have_tag("a", :text => "Add a new sound")
  end

end

