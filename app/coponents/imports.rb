class Imports < Netzke::Basepack::Grid
  
  plugin :grid_live_search do |c|
    c.klass = Netzke::Basepack::GridLiveSearch
    c.delay = 1 # our tests require immediate update
  end
  
  def configure(c)
    super
    c.model = "Import"
    c.tbar = [
      "fn:", {xtype: 'textfield', attr: :file_name, op: 'contains'},
      "box:", {xtype: 'textfield', attr: :box, op: 'contains'},
      "name:", {xtype: 'textfield', attr: :name, op: 'contains'},
      "thajsko:", {xtype: 'textfield', attr: :thajsko, op: 'contains'}
    ]
  end

  #include PgGridTweaks
end