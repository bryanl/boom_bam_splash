class Sound
  include HasherCrasher::Ohm

  before_save :underscore_name


  private

  def underscore_name
    self.name = name.underscore
  end

end
