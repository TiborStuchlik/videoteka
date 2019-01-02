include ActionView::Helpers::UrlHelper

class MovieList < Netzke::Grid::Base
  include Netzke::Basepack::ActionColumn

  action :reread do |c|
    c.icon = :arrow_refresh
    c.text = "Znova načíst z ČSFD"
  end

  column :actions do |c|
    c.type = :action
    c.actions = [{name: :reread, icon: :arrow_refresh}]
    c.header = ""
    c.width = 20
  end

  def tsql
    "select * from movies"
  end

  def configure(c)
    super
    c.region = :center
    c.title = "SEZNAM"
    c.model = "Movie"
    if component_session[:search_query] && !component_session[:search_query].empty?
        q = "%" + component_session[:search_query] + "%"
        c.scope = lambda {|rel| rel.joins(:movie_roles => :authors).where(["authors.name like ? or movies.name_cs like ?", q, q]) }
    else
        c.scope = lambda {|rel| rel.all }
    end
    c.tbar = [{ xtype: :textfield, fieldLabel: "HLEDEJ", listeners: { change: f('pokus_hokus')}}]
    c.columns = [ :actions,
                  { name: :box__name, width: 100, header: "KRABICE" },
                  { name: :year, width: 60, format: "Y", header: "ROK" },
                  # { name: :rezie, width: 200 },
                  { name: :name_cs, width: 200, header: "NÁZEV" },
                  #{ name: :name_en, width: 200 },
                  #{ name: :plot, width: 300 },
                  { name: :csfd_url, width: 70, header: "ČSFD",
                    getter: ->(r){ link_to(r.csfd_id.to_s, r.csfd_url.to_s) }
                  },
                  { name: :runtime, width: 100, header: "ČAS"},
                  { name: :folder_name, header: "SLOŽKA", width: 300},
                  { name: :updated_at, header: "AKTUALIZOVÁNO", format: "Y/m/d"}
    #{ name: :content_rating, width: 100 }

    ]
  end

  endpoint :select_movie do
    client.netzke_notify(config.client_config['selected_movie_id'])
    #component_session[:selected_movie_id] = p[:movie_id]
  end

  endpoint :reread do |p|
    #component_session[:selected_movie_id] = p[:movie_id]
    #Csfdapi.read_movies(p)
    m = Movie.find(p)
    m_id = nil
    begin
      i = Import.find_by_movie_id(m.id)
      m_id = i.id
    rescue
    end
    #q = m.csfd_url.gsub("https://","").gsub("http://","").gsub("www.csfd.cz/film/","")
    o, h = Csfd.detail(m.csfd_id.to_s)
    Csfd.add(h, m_id, m.id)
    "Reimportovano z ČSFD"
  end

  endpoint :find do |p|
    puts p
    component_session[:search_query] = p
  end

  client_class do |c|

    c.netzke_on_reread = l(<<-JS)
      function(r,t) {
         d = this.netzkeParent.netzkeGetComponent("movie_detail")
         id = r.grid.getStore().getAt(t).id
         this.server.reread(id, function(ret){
              //cb of reread
              d.setHtml(ret)
          }) 
        //var idA = this.getSelectionModel().getSelection().map(function(obj){ 
           //return obj.id;
        //});
        //this.reread(idA);
        //var sd = this.ownerCt.netzkeGetComponent('search_detail')
        //sd.update(t)
      }
    JS

    c.result = l(<<-JS)
      function(r,t) {
        var sd = this.ownerCt.netzkeGetComponent('search_detail')
        sd.update(t)
      }
    JS

    c.pokus_hokus = l(<<-JS)
      function(r,t) {
        this.server.find(t)
        mt = Ext.getCmp('application__movieteka').netzkeGetComponent("movie_list")
        mt.getStore().load()
      }
    JS


    c.init_component = l(<<-JS)
      function(){
        this.callParent();
        t = this
        var view = this.getView();

        view.on('itemclick', function(view, record){
          //this.serverConfig.selected_movie_id = record.get('id')
          t.netzkeParent.reloadDetail(record.get('id'))  
          //d.netzkeReload()
          //tiba
          //this.server.selectMovie();
          //this.fillSearch();
        }, this);
      }
    JS

  end
end