class Sdetail < Netzke::Base
  def configure(c)
    super
    c.region = :east
    c.width = 400
    c.split = true
  end
end