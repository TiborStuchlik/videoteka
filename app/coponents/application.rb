class Application < Netzke::Basepack::Viewport

  # A simple mockup of the User model
  class User < Struct.new(:email, :password)
    def initialize
      self.email = "demo@netzke.org"
      self.password = "netzke"
    end
    def self.authenticate_with?(email, password)
      instance = self.new
      [email, password] == [instance.email, instance.password]
    end
  end

  action :about do |c|
    c.icon = :information
  end

  action :sign_in do |c|
    c.icon = :door_in
  end

  action :sign_out do |c|
    c.icon = :door_out
    c.text = "Sign out #{current_user.email}" if current_user
  end

  js_configure do |c|
    c.layout = :fit
    c.mixin
  end

  def configure(c)
    super
    c.intro_html = "Click on a demo component in the navigation tree"
    c.items = [
      { layout: :border,
        tbar: [header_html],
        items: [
          { region: :west, item_id: :navigation, width: 170, split: true, xtype: :treepanel, root: menu, root_visible: false, border: false, title: "Navigation" },
          { region: :center, layout: :border, border: false, items: [
            { item_id: :main_panel, region: :center, layout: :fit, border: false, items: [{border: false, body_padding: 5, html: "Components will be loaded in this area"}] } # items is only needed here for cosmetic reasons (initial border)
          ]}
        ]
      }
    ]
  end

  #
  # Components
  #
  
  component :from_text do |c|
    c.desc = "Grid configured with just a model. Implements infinite scrolling, per-column filtering, sorting, and CRUD operations. " + source_code_link(c)
  end
  
  
  component :movies do |c|
    c.desc = "Grid configured with just a model. Implements infinite scrolling, per-column filtering, sorting, and CRUD operations. " + source_code_link(c)
  end


  # Endpoints
  #
  #
  endpoint :sign_in do |params|
    user = User.new
    if User.authenticate_with?(params[:email], params[:password])
      session[:user_id] = 1 # anything; this is what you'd normally do in a real-life case
      true
    else
      this.netzke_feedback("Wrong credentials")
      false
    end
  end

  endpoint :sign_out do |params|
    session[:user_id] = nil
    true
  end

protected

  def current_user
    @current_user ||= session[:user_id] && User.new
  end

  def link(text, uri)
    "<a href='#{uri}'>#{text}</a>"
  end

  def source_code_link(c)
    "<a href='' target='_blank'>Source code</a>"
  end

  def header_html
    %Q{
      <div style="font-size: 150%;">
       Videotéka v. 0.0.1
      </div>
    }
  end

  def leaf(text, component, icon = nil)
    { text: text,
      id: component,
      icon: uri_to_icon(icon),
      cmp: component,
      leaf: true
    }
  end

  def menu
    out = { :text => "Navigace",
      :expanded => true,
      :children => [

        { :text => "Prohlížení",
          :expanded => true,
          :children => [{
            :text => "Filmy",  
            :expanded => true,
            :children => [
              leaf("Seznam", :movies, :film),
              leaf("Filmotéka", :movieteka, :bullet_black),
       
            ]},
            leaf("Autoři", :actors, :bullet_black),
            leaf("Role", :roless, :bullet_black),
            leaf("Žánry", :genres, :bullet_black),
            leaf("Země", :countries, :bullet_black),
            leaf("Krabice", :boxes, :bullet_black),
            leaf("Soubory", :files, :bullet_black),
            leaf("Originální Média", :mediums, :bullet_black),
            leaf("Přenosná média", :transports, :bullet_black),
            {
            :text => "Imports",  
            :expanded => true,
            :children => [
              leaf("Z textu", :from_text, :bullet_black),
              leaf("Ruřně", :handy, :bullet_black),
       
            ]}
          ]
        },

        { :text => "Editace",
          :expanded => true,
          :children => [
            leaf("Přidávání filmů", :accordion_with_grids, :bullet_black),
          ]
        }
      ]
    }

    if current_user
      out[:children] << { text: "Private components", expanded: true, children: [ leaf("For authenticated users", :for_authenticated, :lock) ]}
    end

    out
  end
end