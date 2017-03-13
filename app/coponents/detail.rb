class Detail < Netzke::Base
  
  action :hledej do |c|
    c.text = "HLEDEJ"
  end
  
  def configure(c)
    super
    #    c.items = [
    #  { component: :imports, title: "Imports", region: "center" },
    #  { component: :search_detail, title: "Hledat", region: "east" }
    #]
    c.region = :center
    #c.tbar = [{ xtype: :textfield}, :hledej]
    c.layout = :fit
    c.title = "IMPORT Z WEBU CSFD"
    c.html = Csfd.detail('234976-zelena-zona')
    c.html = "<div style='height: 100%; overflow: scroll;'>" + c.html + "</div>"

  end


  client_class do |c|
    c.layout = :border
    c.init_component = l(<<-JS)
       function(){
         this.callParent();
       }
    JS
    
    c.netzke_on_hledej = l(<<-JS)
       function(){
         this.serverConfig.search_text = ("pasla")
         this.server.search()
         //this.server.hledej(text);
       }
    JS
    
  end
  
  component :search_detail do |c|
    c.desc = "Hledani"
  end

  component :search_list do |c|
    c.desc = "Hledani seznam"
  end

  
  component :imports do |c|
    c.desc = "Položky připravené k importu"
  end
  #include PgGridTweaks
end




