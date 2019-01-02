class MovieDetail < Netzke::Base

  def configure(c)
    super
    @id = c.client_config[:selected_movie_id]
    puts "ID: " + @id.to_s
    c.title = "DETAIL"
    c.region = :east
    c.width = 500
    c.split = true
    c.html = "<div style='padding: 5px'>Pro více podrobností vyberte film v levém panelu.</div>"
  end


end