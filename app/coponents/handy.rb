class Handy < Netzke::Base
  

  def configure(c)
    super
    c.items = [
      { component: :search_list },
      { component: :sdetail}
      #{ component: :search_detail, title: "Hledat", region: "east" }
    ]
    c.region = :center
    #c.tbar = [{ xtype: :textfield, id: "search_text"}, :hledej]
    c.layout = :border
    #c.title = "IMPORT Z WEBU CSFD"
    #c.html = "Zadej text pro vyhledání v CSFD."
  end

  component :sdetail
  component :search_list

 client_class do |c|
    c.layout = :border
    c.init_component = l(<<-JS)
       function(){
         this.callParent();
       }
    JS
    
    c.netzke_on_hledej = l(<<-JS)
       function(){
        
         //this.server.search(Ext.getCmp('search_text').value)
         
       }
    JS

   c.set_detail = l(<<-JS)
       function(data){
          d = this.netzkeGetComponent("sdetail")
          d.setHtml(data)
          //alert(data)         
       }
   JS

 end
  

end




