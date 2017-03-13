class Csfd < Object
  
  @@host = "www.csfd.cz"
  @@protocol = "http"
  
  def self.makebox(*info)
    o = "<table border='1' style='border: 1px'><tr>"
    info.each do |i|
      o += "<td style='max-width: 400px; padding: 10px; border: 1px black solid'>" + i + "</td>"
    end
    o += "</tr></table>"
  end
  
  def self.detail(p)
    uri = URI.parse("#{@@protocol}://#{@@host}/film/" + p + "/prehled/" )
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    hres = http.request(request).body
    hres = Nokogiri::HTML(hres)
    
    out = "<div>"
    oa = []
    res = hres.css('div#main')
    
    #poster image
    res_poster = res.css('img.film-poster')
    poster_info = res_poster.attribute('src')
    oa << makebox(res_poster.to_s, poster_info, "image_url")    
    
    #neme cs
    nazev = res.css('h1[@itemprop = "name"]')
    oa << makebox(nazev.to_s, nazev.text.strip ,"name_cs")
    
    #dalsi nazvy
    nazvy = res.css('ul.names')
    nazvy.css('li').each do |n|
      t = "name_" + n.css('img').attribute('alt').to_s
      nn = n.css('h3').text
      oa << makebox(n.to_s, nn , t)
    end
    
    #genre
    genres = res.css('p.genre').text
    ga = genres.split(" / ")
    ga.each do |g|
      oa << makebox(genres, g, "genre_" + g)
    end
  
    #zeme
    country = res.css('p.origin').text
    ga = country.split(", ")
    
    ga[0].split(" / ").each do |g|
      oa << makebox( country, g, "country_" + g)
    end

    #rok vyroby
    oa << makebox( country, ga[1], "year_" + ga[1])
    
    #duration
    oa << makebox( country, ga[2], "duration_" + ga[2])
    
    #people
    cre = res.css("div.creators div")
    cre.css("div").each do |c|
      dd = c.css('h4')
      d = dd.text.gsub(":","")
      next if c.attribute('id').to_s == "next-professions"
      aa = []
      c.css('span a').each do |a|
        aa << makebox( a.to_s, a.text , "creator_" + a.text)
      end
      aao = "<div>" + aa.join + "</div>"
      oa << makebox( c.to_s, d, "role_" + d + aao )
      #oa << makebox( c.to_s, "x", "creator_" )
    end
    
    #text
    txt = res.css('div#plots div.content ul li')
    tx = txt.first.css('div').first
    oa << makebox( tx.to_s, tx.text, "text" )
    
    
    out += oa.join("<hr/>")
    
    out += "<hr/>" + "<hr/>"
    out += res.to_s
    out += "</div>"

  end
   
  def self.search(p)
    uri = URI.parse("#{@@protocol}://#{@@host}/hledat/?" + p.to_query )
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    hres = http.request(request).body
    hres = Nokogiri::HTML(hres)  
    res = hres.css('div#search-films ul.ui-image-list')
    liv = []
    res.css('li').each do |r|
      puts r
      puts "--------------"
      liv.push r
    end
    res = hres.css('div#search-films ul.films')
    lim = []
    res.css('li').each do |r|
      puts r
      puts "--------------"
      lim.push r
    end
    [liv,lim]
  end
  
  #old
  
  
  def self.read_movies(ma)
    csfd = self.new
    ma.each do |m|
      csfd.read_movie m
    end
  end
  
  def read_movie(id)
    m = Movie.find(id)
    uri = URI.parse("http://csfdapi.cz/movie/" + m.csfd_id.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    json = http.request(request).body
    result = JSON.parse(http.request(request).body)
    puts ">>>>>> " + m.id.to_s
    add_movie(result,m)
  end
  
  def add_movie(mh, m)
   
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