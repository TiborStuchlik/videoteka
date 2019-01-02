require "json"
require "net/http"

include ActionView::Helpers::UrlHelper

class Imports < Netzke::Grid::Base
  
  plugin :grid_live_search do |c|
    c.klass = Netzke::Basepack::GridLiveSearch
    c.delay = 1 # our tests require immediate update
  end

  
  def configure(c)
    super
    c.model = "Import"
    c.columns = [
      {width: 70,name: :thajsko},
      {width: 70,
       name: :mtext
      },
      {width: 220, name: :file_name}, 
      {width: 150, name: :box}, 
      {width: 250, name: :name}, 
      {width: 70,name: :count}, 
      
      ]
    c.tbar = [
      "fn:", {xtype: 'textfield', attr: :file_name, op: 'contains'},
      "box:", {xtype: 'textfield', attr: :box, op: 'contains'},
      "name:", {xtype: 'textfield', attr: :name, op: 'contains'},
      "thajsko:", {xtype: 'textfield', attr: :thajsko, op: 'contains'}
    ]
  end

  client_class do |c|
        
    c.result = l(<<-JS)
      function(r,t) {
        var sd = this.ownerCt.netzkeGetComponent('search_detail')
        sd.update(t)
      }
    JS

    c.on_get_detail = l(<<-JS)
      function(r,id) {
        //alert("tiba: " + r + " id:" + id)
        d = this.netzkeParent.netzkeGetComponent("search_detail")
        this.server.addImport(r,id, function(ret){
          d.setHtml(ret)
        })
        //var sd = this.ownerCt.netzkeGetComponent('search_detail')
        //sd.update(t)
      }
    JS

    c.init_component = l(<<-JS)
      function(){
        this.callParent();
        var view = this.getView();

        view.on('itemclick', function(view, record){
          this.server.selectImport({import_id: record.get('id')});
          this.server.fillSearch();
        }, this);
      }
    JS
  end

  endpoint :add_import do |p,i|
    txt = p.gsub("/film/","").gsub("/","")
    _, rh = Csfd.detail(txt)
    Csfd.add(rh, i)
    "Záznam naimportován."
  end

  endpoint :select_import do |p|
    component_session[:selected_import_id] = p[:import_id]
  end  
  
  endpoint :csfd_search do |p|
    if component_session[:selected_import_id]
      iid = component_session[:selected_import_id]
      i = Import.find(iid)
      r = csfd_search(p, iid)
      client.result(r, r)
    else
      client.result("Nejprve vyberte zaznam k importu.")
    end

      #iid = component_session[:selected_import_id]
    #i = Import.find(iid)
    #r = csfd_search(p)
    #client.netzke_feedback(p)
    #client.result(r, (r.map {|m| m[0]}).join)
 end 


  endpoint :fill_search do
    iid = component_session[:selected_import_id]
    i = Import.find(iid)
    r = csfd_search(i.name, iid)
    #t.netzke_feedback(i.name)
    client.result(r, r)
 end 
  
  def make_html(doc,json)
    o = "<div style='padding: 10px'><table border='1'><tr>"
    o += "<td><input value='import' type='button' onclick='Ext.getCmp(\"application__from_text__search_detail\").addImport({\"import_id\":" + component_session[:selected_import_id].to_s + ", \"csfd_id\":" + doc["id"].to_s + ", \"obj\":" + json + "})'></td>"
    o += "<td><img src='" + doc["poster_url"].to_s + "'></td>"
    o += "<td>"
    o += "<div>id: " + link_to(doc["id"].to_s, doc["csfd_url"].to_s) + "</div>"
    o += "<div>name cs: " + doc["names"]["cs"].to_s + "</div>"
    o += "<div>rok: " + doc["year"].to_s + "</div>"
    if doc['countries']
      o += "<div>zeme: " 
      o += doc['countries'].map {|c| c }.join(', ') 
      o += "</div>"
    end  
    if doc['genres']
      o += "<div>zanr: " 
      o += doc['genres'].map {|c| c }.join(', ') 
      o += "</div>"
    end  
      o += "</td>"
      o += "</tr></table></div>"
    o
  end
  
  def csfd_search(val, iid)

    oa,ob = Csfd.search(q: val.gsub("_"," "))
    oas = oa.map do |x|
      ref = x.css('a').attribute('href').to_s
      "<table><tr><td style='width: 100%'>" + x.to_s + "</td><td><input type=button value='PRIDEJ' onclick='Ext.getCmp(\"application__from_text__imports\").onGetDetail(\"" + ref + "\"," + iid.to_s + ")'></td></tr></table><hr/>"
    end
    obs = ob.map do |x|
      ref = x.css('a').attribute('href').to_s
      "<table><tr><td style='width: 100%'>" + x.to_s + "</td><td><input type=button value='PRIDEJ' onclick='Ext.getCmp(\"application__from_text__imports\").onGetDetail(\"" + ref + "\"," + iid.to_s + ")'></td></tr></table><hr/>"
    end
    rr = oas + obs
    html = "<ul class='ui-image-list js-odd-even'>" + rr.join + "<ul/>"
    html = "<div style='height: 100%; overflow: scroll;'>" + html + "</div>"
    html
  end
end