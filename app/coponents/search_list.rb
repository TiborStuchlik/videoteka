class SearchList < Netzke::Base

  action :hledej do |c|
    c.text = "HLEDEJ"
  end

  def configure(c)
    super
    c.title = "HLEDAT"
    c.region = :center
    c.layout = :fit
    c.tbar = [{ xtype: :textfield, id: "search_text"}, :hledej]
    c.html = "Zadej text pro vyhledání v CSFD."
  end

  endpoint :search do |p|
    t = get_html(p.to_s)
    client.netzke_notify("HLEDÁM: " + p.to_s)
    client.setHtml(t)
  end

  endpoint :detail do |p|
    "<div style='height: 100%; overflow: scroll;'>" + get_detail(p) + "</div>"
  end

  endpoint :add_movie do |p|
    po = p.gsub('/film/',"").gsub("/","")
    d, h = Csfd.detail(po)
    Csfd.add(h)
    "Importovano z ČSFD"
  end

  def get_detail(p)
    po = p.gsub('/film/',"").gsub("/","")
    d, h = Csfd.detail(po)
    d
  end

  def get_html(val = "kosta")
    oa,ob = Csfd.search(q: val)
    oas = oa.map do |x|
      ref = x.css('a').attribute('href').to_s
      puts "---------------------------------------------"
      "<table><tr><td style='width: 100%'>" + x.to_s + "</td>" +
      "<td><input type=button value='DETAIL' onclick='Ext.getCmp(\"application__handy__search_list\").onGetDetail(\"" + ref + "\")'></td>" +
      "<td><input type=button value='PŘIDEJ' onclick='Ext.getCmp(\"application__handy__search_list\").onAddDetail(\"" + ref + "\")'></td>" +
      "</tr></table><hr/>"
    end
    obs = ob.map {|x| x.to_s + "<hr/>"}
    rr = oas + obs
    html = "<ul class='ui-image-list js-odd-even'>" + rr.join + "<ul/>"
    html = "<div style='height: 100%; overflow: scroll;'>" + html + "</div>"
    html
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

    c.on_get_detail = l(<<-JS)
       function(data){
          cmp = this  
          this.server.detail(data, function(ret) {
              cmp.netzkeParent.setDetail(ret)
          });         
       }
    JS

    c.on_add_detail = l(<<-JS)
       function(data, imp){
          cmp = this  
          d = this.netzkeParent.netzkeGetComponent('sdetail')
          this.server.addMovie(data, imp, function(ret) {
              //cmp.netzkeParent.setDetail(ret)
              d.setHtml(ret)
          });         
       }
    JS

  end

end




