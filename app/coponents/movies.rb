include ActionView::Helpers::UrlHelper

class Movies < Netzke::Grid::Base
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

  def configure(c)
    super
    c.model = "Movie"
    c.tbar = [:reread]
    c.columns = [ :actions,
      { name: :box__name, width: 100 },
      { name: :year, width: 60, format: "Y" },
     # { name: :rezie, width: 200 },
      { name: :name_cs, width: 200 },
      #{ name: :name_en, width: 200 },
      #{ name: :plot, width: 300 },
      { name: :csfd_url, width: 70,
        getter: ->(r){ link_to(r.csfd_id, r.csfd_url) }
      },
      { name: :runtime, width: 100 },
      #{ name: :content_rating, width: 100 }

      ]
  end
  
  endpoint :select_movie do 
    client.netzke_notify(config.client_config['selected_movie_id'])
    #component_session[:selected_movie_id] = p[:movie_id]
  end

  endpoint :reread do |p|
    #component_session[:selected_movie_id] = p[:movie_id]
    Csfdapi.read_movies(p)

  end


  client_class do |c|

    c.onReread = l(<<-JS)
      function(r,t) {
        var idA = this.getSelectionModel().getSelection().map(function(obj){ 
        return obj.id;
        });
        this.reread(idA);
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
    
    c.init_component = l(<<-JS)
      function(){
        this.callParent();
        var view = this.getView();

        view.on('itemclick', function(view, record){
          this.serverConfig.selected_movie_id = record.get('id')
          this.server.selectMovie();
          //this.fillSearch();
        }, this);
      }
    JS
    
  end  
end