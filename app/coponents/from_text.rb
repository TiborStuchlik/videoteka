class FromText < Netzke::Base
  def configure(c)
    #super
        c.items = [
      { netzke_component: :imports, title: "Imports", region: "center" },
    ]
  end
  
  component :imports do |c|
    c.desc = "Položky připravené k importu"
  end
  #include PgGridTweaks
end




