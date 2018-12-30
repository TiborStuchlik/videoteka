class Countries < Netzke::Grid::Base

  def configure(c)
    c.model = "Country"
  end
end
