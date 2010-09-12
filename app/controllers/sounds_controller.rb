class SoundsController < ApplicationController
  def index
    @sounds = Sound.all
  end

  def new
    @sound = Sound.new
  end

  def create
    @sound = Sound.new params[:sound]
    if @sound.save
      redirect_to sounds_path
    else
      render :action => "new"
    end
  end

  def show
    @sound = Sound.find params[:id]
    send_data @sound.data, :filename => "sound.mp3", :type => "audio/mpeg"
  end
end
