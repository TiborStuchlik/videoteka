class Movies < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Movie"
  end

  #include PgGridTweaks
end