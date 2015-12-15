require "json"
require "net/http"

include ActionView::Helpers::UrlHelper

class Imports < Netzke::Basepack::Grid
  
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

  js_configure do |c|
        
    c.result = <<-JS
      function(r,t) {
        var sd = this.ownerCt.netzkeGetComponent('search_detail')
        sd.update(t)
      }
    JS
    c.init_component = <<-JS
      function(){
        this.callParent();
        var view = this.getView();

        view.on('itemclick', function(view, record){
          this.selectImport({import_id: record.get('id')});
          this.fillSearch();
        }, this);
      }
    JS
  end  

  endpoint :select_import do |p,t|
    component_session[:selected_import_id] = p[:import_id]
  end  
  
  endpoint :csfd_search do |p,t|
    #iid = component_session[:selected_import_id]
    #i = Import.find(iid)
    r = csfd_search(p)
    t.netzke_feedback(p)
    t.result(r, (r.map {|m| m[0]}).join)
 end 


  endpoint :fill_search do |p,t|
    iid = component_session[:selected_import_id]
    i = Import.find(iid)
    r = csfd_search(i.name)
    t.netzke_feedback(i.name)
    t.result(r, (r.map {|m| m[0]}).join)
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
  
  def csfd_search(val)
    st = URI.escape(val.gsub(" ", "+").gsub("_","+"))
    uri = URI.parse("http://csfdapi.cz/movie?search='" + st + "'")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    json = http.request(request).body
    result = JSON.parse(http.request(request).body)
    r = []
    result.each do |doc|
      r << [make_html(doc,doc.to_json), doc, json]
    end
    r
  end
end