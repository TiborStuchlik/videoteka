class MovieCountries < Netzke::Grid::Base

  def configure(c)
    c.model = "Country"
    c.height = 300
  end

end