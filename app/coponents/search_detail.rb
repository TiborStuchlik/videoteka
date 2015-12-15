class SearchDetail < Netzke::Base
  def configure(c)
    #super
    c.autoScroll = true
    c.title = "detail hledani"
    c.width = 600
  end
  
  js_configure do |c|
        
    c.add = <<-JS
      function(r,t) {
       alert('import')
      }
    JS
  end
  
  endpoint :add_import do |p,t|
    i = Import.find(p['import_id'])
    add_movie(p['obj'], i)
    x = read_movie(p['csfd_id'], i)
    i.movie_id = x.id
    i.save
    t.netzke_feedback("import")
  end
  
  def read_movie(val, i)
    uri = URI.parse("http://csfdapi.cz/movie/" + val.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    json = http.request(request).body
    result = JSON.parse(http.request(request).body)
    add_movie(result, i)
  end
  
  def add_movie(mh, i)
    m = Movie.find_by_csfd_id(mh['id'])
    if !m
      m = Movie.new( csfd_id: mh['id'])
    end
    
    if mh['names']
      mm = mh['names']
      m[:name_cs] = mm['cs'] if !mm['cs'].blank? 
      m[:name_en] = mm['anglický'] if mm['anglický']
      m[:name_sk] = mm['sk'] if mm['sk']
    end
    m[:year] = Date.parse(mh['year'].to_s + "0101") if mh['year']
    m[:poster_url] = mh['poster_url'] if mh['poster_url']
    m[:csfd_url] = mh['csfd_url'] if mh['csfd_url']
    m[:plot] = mh['plot'] if mh['plot']
    m[:api_url] = mh['api_url'] if mh['api_url']
    m[:runtime] = mh['runtime'] if mh['runtime']
    m[:content_rating] = mh['content_rating'] if mh['content_rating']
    add_box(m,i)
    m.save
    add_genres(mh['genres'], m) if mh['genres'] 
    add_countries(mh['countries'], m) if mh['countries'] 
    add_roles(mh['authors'], m) if mh['authors'] 
    m

  end
  
  def add_box(m,i)
    b = Box.find_or_create_by( name: i.box)
    m.box = b
  end
  
  def add_genres(gs, m)
    gs.each do |g|
      g = Genre.where(name: g).first_or_create
      if !m.genre_ids.include?(g.id)
       m.genres << g
      end 
    end
    
  end
  
  def add_countries(gs, m)
    gs.each do |g|
      g = Country.where(name: g).first_or_create
      if !m.country_ids.include?(g.id)
       m.countries << g
      end 
    end
    
  end
  
  def add_roles(gs, m)
    gs.each do |g,h|
      r = Role.find_or_create_by(name: g)
      m.roles << r if !m.roles.include?(r)
      m.reload
      mr = m.movie_roles.find_by_role_id(r.id)
 
      h.each do |a|
       au = Author.find_or_create_by({ csfd_id: a['id']})
       au.name = a['name'] if !a['name'].blank?
       au.api_url = a['api_url'] if !a['api_url'].blank?
       au.csfd_url = a['csfd_url'] if !a['csfd_url'].blank?
       au.address = a['address'] if !a['address'].blank?
       au.born = a['born'] if !a['born'].blank?
       au.portrait_url = a['portrait_url'] if !a['portrait_url'].blank?
       au.bio = a['bio'] if !a['bio'].blank?
       au.filmography = a['filmography'] if !a['filmography'].blank?
       au.imdb_url = a['imdb_url'] if !a['imdb_url'].blank?
       au.save
       mr.authors << au unless mr.authors.include?(au)
      end
    end
    
  end
end




