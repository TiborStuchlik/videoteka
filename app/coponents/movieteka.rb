class Movieteka < Netzke::Base

  def configure(c)
    c.items = [
        { component: :movie_list },
        { component: :movie_detail}
    ]
    c.layout = :border
  end

  endpoint :select_movie do |p|
    out = ""
    m = Movie.find(p)
    out += "<img src='" + m.poster_url.to_s + "'><hr/>"
    out += "<b>Žánr: </b>" + m.genres.map {|c| c.name}.join(", ")
    out += "<hr/>"
    out += "<b>Země: </b>" + m.countries.map {|c| c.name}.join(", ")
    out += "<hr/>"
    m.movie_roles.each do |r|
      out += "<b>" + r.role.name + ": </b>" + r.authors.map {|a| a.name}.join(", ")
      out += "<hr/>"
    end
    out = "<div style='padding: 5px;'>" + out + "</div>"
  end

  component :movie_list
  component :movie_detail

  client_class do |c|

    c.reload_detail = l(<<-JS)
      function(id) {
        me = this
        detail = me.netzkeGetComponent("movie_detail")
        //me.netzkeReloadChild(detail, {selected_movie_id: id})
        //this.serverConfig.selected_movie_id = id
        this.server.selectMovie(id, function(data) {
          detail.setHtml(data)       
        //    me.netzkeGetComponent("movie_detail").netzkeReload({ pok: "hok"})
        })
        //this.netzkeGetComponent("movie_detail").netzkeReload()
      }
    JS

   end

end