class Handy < Netzke::Base
  
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
    c.tbar = [{ xtype: :textfield, id: "search_text"}, :hledej]
    c.layout = :fit
    c.title = "IMPORT Z WEBU CSFD"
    c.html = "Zadej text pro vyhledání v CSFD."
  end

  
def get_html(val = "kosta")
    oa,ob = Csfd.search(q: val)
    oas = oa.map {|x| x.to_s + "<hr/>"}
    obs = ob.map {|x| x.to_s + "<hr/>"}
    rr = oas + obs
    html = "<ul class='ui-image-list js-odd-even'>" + rr.join + "<ul/>"
    html = "<div style='height: 100%; overflow: scroll;'>" + html + "</div>"
    html
end  
  
endpoint :search do |p|
  
  t = get_html(p.to_s)
  client.netzke_notify("HLEDÁM: " + p.to_s)
  client.setHtml(t)
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
        
         this.server.search(Ext.getCmp('search_text').value)
         
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




