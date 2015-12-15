include ActionView::Helpers::UrlHelper

class Movies < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Movie"
    c.columns = [
      { name: :box__name, width: 100 },
      { name: :year, width: 60, format: "Y" },
     # { name: :rezie, width: 200 },
      { name: :name_cs, width: 200 },
      { name: :name_en, width: 200 },
      { name: :plot, width: 300 },
      { name: :csfd_url, width: 70, 
        getter: ->(r){ link_to(r.csfd_id, r.csfd_url) }
      },
      { name: :runtime, width: 100 },
      { name: :content_rating, width: 100 },
      { name: :folder_name, width: 100 },

      ]
  end

  #include PgGridTweaks
end