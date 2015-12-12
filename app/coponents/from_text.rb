class FromText < Netzke::Base
  def configure(c)
    #super
        c.items = [
      { netzke_component: :imports, title: "Imports", region: "center" },
      { netzke_component: :search_detail, title: "Hledat", region: "east" }
    ]
  end

 js_configure do |c|
    c.layout = :border
    c.init_component = <<-JS
       function(){
         this.callParent();
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




